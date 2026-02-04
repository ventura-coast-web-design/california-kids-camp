# frozen_string_literal: true

class AttendeeRegistrationsController < ApplicationController
  # Set Stripe API key
  before_action :set_stripe_key
  before_action :check_stripe_configured, only: [ :payment, :create_payment_intent ]

  # GET /attendees/register
  def new
    @attendee_registration = AttendeeRegistration.new
    # Start with one attendee form by default
    @attendee_registration.attendees.build
  end

  # GET /attendee_registrations/:id
  def show
    @attendee_registration = AttendeeRegistration.find(params[:id])

    # Only show confirmation if payment is completed
    unless @attendee_registration.paid?
      flash[:alert] = "Payment not completed for this registration."
      redirect_to root_path
      nil
    end
  end

  # POST /attendee_registrations
  def create
    @attendee_registration = AttendeeRegistration.new(attendee_registration_params)

    # Validate without saving
    if @attendee_registration.valid?
      # Clear any existing pending registration to prevent stale data
      old_registration_data = session[:pending_registration]

      # Cancel any existing payment intents from previous registration attempts
      if old_registration_data
        old_payment_intent_id = old_registration_data[:stripe_payment_intent_id] || old_registration_data["stripe_payment_intent_id"]
        if old_payment_intent_id.present?
          begin
            old_payment_intent = Stripe::PaymentIntent.retrieve(old_payment_intent_id)
            # Cancel payment intent if it's still in a cancellable state
            if [ "requires_payment_method", "requires_confirmation" ].include?(old_payment_intent.status)
              Stripe::PaymentIntent.cancel(old_payment_intent_id)
            end
          rescue Stripe::StripeError => e
            # Log error but don't fail the registration
            Rails.logger.warn "Failed to cancel old payment intent #{old_payment_intent_id}: #{e.message}"
          end
        end
      end

      session.delete(:pending_registration)

      # Store registration data in session temporarily
      # Convert to hash and ensure nested attributes are preserved
      temp_id = SecureRandom.uuid
      registration_params_hash = attendee_registration_params.to_unsafe_h

      # Set pricing_type before storing in session
      pricing_type = @attendee_registration.early_bird_eligible? ? "early_bird" : "regular"
      registration_params_hash["pricing_type"] = pricing_type

      session[:pending_registration] = {
        "id" => temp_id,
        "data" => registration_params_hash,
        "created_at" => Time.current.to_s
      }

      redirect_to payment_attendee_registration_path(temp_id)
    else
      flash.now[:alert] = "There was an error with your registration. Please check the form and try again."
      render :new, status: :unprocessable_entity
    end
  end

  # GET /attendee_registrations/:id/payment
  def payment
    # Check if this is a temporary ID (UUID) or a real database ID
    temp_id = params[:id]
    registration_data = session[:pending_registration]

    # Check if it's a UUID format
    is_uuid = temp_id.match?(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)

    # If it's a UUID, we expect session data
    if is_uuid
      # Handle both symbol and string keys for session data
      reg_id = registration_data&.dig(:id) || registration_data&.dig("id")

      if registration_data.nil? || reg_id != temp_id
        flash[:alert] = "Registration session expired. Please start over."
        redirect_to new_attendee_path
        return
      end

      # Load registration from session - handle both symbol and string keys
      reg_data = registration_data[:data] || registration_data["data"]
      @attendee_registration = AttendeeRegistration.new(reg_data.with_indifferent_access)
      # Set pricing_type if not already set (will be set by before_validation callback, but ensure it's set for calculations)
      @attendee_registration.pricing_type ||= @attendee_registration.early_bird_eligible? ? "early_bird" : "regular"
      @temp_registration_id = temp_id
    else
      # Not a UUID, try to find existing registration (backward compatibility)
      @attendee_registration = AttendeeRegistration.find_by(id: temp_id)
      if @attendee_registration.nil?
        flash[:alert] = "Registration not found."
        redirect_to new_attendee_path
        return
      end

      if @attendee_registration.paid?
        flash[:notice] = "Payment already completed for this registration."
        redirect_to root_path
        return
      end
    end

    # Check if Stripe is configured
    unless ENV["STRIPE_API_KEY"].present? && ENV["STRIPE_PUBLISHABLE_KEY"].present?
      Rails.logger.error "Stripe configuration missing. STRIPE_API_KEY present: #{ENV['STRIPE_API_KEY'].present?}, STRIPE_PUBLISHABLE_KEY present: #{ENV['STRIPE_PUBLISHABLE_KEY'].present?}"
      flash[:alert] = "Payment system is not configured. Please ensure STRIPE_API_KEY and STRIPE_PUBLISHABLE_KEY are set in your .env file and restart the server."
      redirect_to root_path
      return
    end

    @amount = @attendee_registration.calculate_total_amount
    @deposit_amount = @attendee_registration.calculate_deposit_amount
    @child_count = @attendee_registration.attendees.reject(&:marked_for_destruction?).count
    @stripe_publishable_key = ENV["STRIPE_PUBLISHABLE_KEY"]
  end

  # POST /attendee_registrations/:id/create_payment_intent
  def create_payment_intent
    temp_id = params[:id]
    registration_data = session[:pending_registration]

    # Check if it's a UUID format
    is_uuid = temp_id.match?(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)

    # Load registration from session
    if is_uuid && registration_data
      reg_id = registration_data[:id] || registration_data["id"]
      if reg_id == temp_id
        reg_data = registration_data[:data] || registration_data["data"]
        @attendee_registration = AttendeeRegistration.new(reg_data.with_indifferent_access)
        # Set pricing_type if not already set
        @attendee_registration.pricing_type ||= @attendee_registration.early_bird_eligible? ? "early_bird" : "regular"
      else
        render json: { error: "Registration session expired. Please start over." }, status: :unprocessable_entity
        return
      end
    else
      # Fallback: try to find existing registration (for backward compatibility)
      @attendee_registration = AttendeeRegistration.find_by(id: temp_id)
      unless @attendee_registration
        render json: { error: "Registration session expired. Please start over." }, status: :unprocessable_entity
        return
      end
    end

    begin
      # Get payment type from request (deposit or full)
      payment_type = params[:payment_type] || "deposit"

      # Calculate amount based on payment type
      amount_in_cents = if payment_type == "deposit"
                          @attendee_registration.deposit_amount_in_cents
      else
                          @attendee_registration.amount_in_cents
      end

      # Store payment intent ID in session for temporary registrations
      reg_id = registration_data&.dig(:id) || registration_data&.dig("id")
      if is_uuid && registration_data && reg_id == temp_id
        # Check if payment intent already exists in session
        existing_intent_id = registration_data[:stripe_payment_intent_id] || registration_data["stripe_payment_intent_id"]
        if existing_intent_id.present?
          payment_intent = Stripe::PaymentIntent.retrieve(existing_intent_id)

          # If payment intent is still in a processable state and matches the requested amount, reuse it
          if [ "requires_payment_method", "requires_confirmation" ].include?(payment_intent.status) &&
             payment_intent.amount == amount_in_cents
            render json: {
              clientSecret: payment_intent.client_secret
            }
            return
          end
        end

        # Create new payment intent
        payment_intent = Stripe::PaymentIntent.create(
          amount: amount_in_cents,
          currency: "usd",
          metadata: {
            temp_registration_id: temp_id,
            guardian_email: @attendee_registration.guardian_1_email,
            payment_type: payment_type
          }
        )

        # Update session with payment intent ID (handle both string and symbol keys)
        session[:pending_registration] ||= {}
        session[:pending_registration]["stripe_payment_intent_id"] = payment_intent.id
        session[:pending_registration]["payment_type"] = payment_type
        session[:pending_registration][:stripe_payment_intent_id] = payment_intent.id
        session[:pending_registration][:payment_type] = payment_type
      else
        # Existing registration flow (backward compatibility)
        if @attendee_registration.stripe_payment_intent_id.present?
          payment_intent = Stripe::PaymentIntent.retrieve(@attendee_registration.stripe_payment_intent_id)

          if [ "requires_payment_method", "requires_confirmation" ].include?(payment_intent.status) &&
             payment_intent.amount == amount_in_cents
            render json: {
              clientSecret: payment_intent.client_secret
            }
            return
          end
        end

        payment_intent = Stripe::PaymentIntent.create(
          amount: amount_in_cents,
          currency: "usd",
          metadata: {
            attendee_registration_id: @attendee_registration.id,
            guardian_email: @attendee_registration.guardian_1_email,
            payment_type: payment_type
          }
        )

        @attendee_registration.update(
          stripe_payment_intent_id: payment_intent.id,
          payment_type: payment_type
        )
      end

      render json: {
        clientSecret: payment_intent.client_secret
      }
    rescue Stripe::StripeError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  # POST /attendee_registrations/:id/payment_success
  def payment_success
    temp_id = params[:id]
    registration_data = session[:pending_registration]
    payment_intent_id = params[:payment_intent_id]

    # Check if this is a UUID (temporary registration)
    is_uuid = temp_id.match?(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)

    # Check if this is a temporary registration or existing one
    reg_id = registration_data&.dig(:id) || registration_data&.dig("id")
    if is_uuid && registration_data && reg_id == temp_id
      payment_intent_id ||= registration_data[:stripe_payment_intent_id] || registration_data["stripe_payment_intent_id"]

      return redirect_to payment_attendee_registration_path(temp_id) unless payment_intent_id

      begin
        payment_intent = Stripe::PaymentIntent.retrieve(payment_intent_id)

        # Verify this payment intent belongs to this temporary registration
        unless payment_intent.metadata["temp_registration_id"] == temp_id
          flash[:alert] = "Invalid payment. Please try again."
          redirect_to payment_attendee_registration_path(temp_id)
          return
        end

        if payment_intent.status == "succeeded"
          # Check if a registration with this payment intent already exists (idempotency check)
          existing_registration = AttendeeRegistration.find_by(stripe_payment_intent_id: payment_intent_id)
          if existing_registration
            # Payment already processed, redirect to existing registration
            session.delete(:pending_registration)
            redirect_to attendee_registration_path(existing_registration)
            return
          end

          # Get payment_type from metadata first (source of truth), then session, then params, default to 'full'
          payment_type = payment_intent.metadata["payment_type"] ||
                        registration_data[:payment_type] ||
                        registration_data["payment_type"] ||
                        params[:payment_type] ||
                        "full"

          # Create the actual registration record now that payment succeeded
          reg_data = registration_data[:data] || registration_data["data"]
          @attendee_registration = AttendeeRegistration.new(reg_data.with_indifferent_access)
          @attendee_registration.payment_status = "succeeded"
          @attendee_registration.stripe_payment_intent_id = payment_intent_id
          @attendee_registration.amount_paid = payment_intent.amount / 100.0
          @attendee_registration.payment_type = payment_type
          # Set pricing_type if not already set (will be set by before_validation callback, but ensure it's preserved)
          @attendee_registration.pricing_type ||= @attendee_registration.early_bird_eligible? ? "early_bird" : "regular"

          if @attendee_registration.save
            # Clear session data
            session.delete(:pending_registration)

            # Send confirmation email
            RegistrationMailer.attendee_registration_confirmation(@attendee_registration).deliver_later

            redirect_to attendee_registration_path(@attendee_registration)
          else
            flash[:alert] = "There was an error saving your registration. Please contact support."
            redirect_to new_attendee_path
          end
        else
          flash[:alert] = "Payment was not successful. Please try again."
          redirect_to payment_attendee_registration_path(temp_id)
        end
      rescue Stripe::StripeError => e
        flash[:alert] = "There was an error processing your payment: #{e.message}"
        redirect_to payment_attendee_registration_path(temp_id)
      end
    else
      # Existing registration flow (backward compatibility)
      @attendee_registration = AttendeeRegistration.find_by(id: temp_id)
      unless @attendee_registration
        flash[:alert] = "Registration not found."
        redirect_to new_attendee_path
        return
      end

      payment_intent_id ||= @attendee_registration.stripe_payment_intent_id
      return redirect_to payment_attendee_registration_path(@attendee_registration) unless payment_intent_id

      begin
        payment_intent = Stripe::PaymentIntent.retrieve(payment_intent_id)

        # Verify this payment intent belongs to this registration
        unless payment_intent.metadata["attendee_registration_id"].to_i == @attendee_registration.id
          flash[:alert] = "Invalid payment. Please try again."
          redirect_to payment_attendee_registration_path(@attendee_registration)
          return
        end

        if payment_intent.status == "succeeded"
          # Check if payment was already processed (idempotency check)
          was_already_paid = @attendee_registration.payment_status == "succeeded" && @attendee_registration.stripe_payment_intent_id == payment_intent_id
          
          if was_already_paid
            redirect_to attendee_registration_path(@attendee_registration)
            return
          end

          # Get payment_type from metadata first (source of truth), then params, then registration, default to 'full'
          payment_type = payment_intent.metadata["payment_type"] || params[:payment_type] || @attendee_registration.payment_type || "full"

          @attendee_registration.update(
            payment_status: "succeeded",
            stripe_payment_intent_id: payment_intent_id,
            amount_paid: payment_intent.amount / 100.0,
            payment_type: payment_type
          )

          # Send confirmation email
          RegistrationMailer.attendee_registration_confirmation(@attendee_registration).deliver_later

          redirect_to attendee_registration_path(@attendee_registration)
        else
          flash[:alert] = "Payment was not successful. Please try again."
          redirect_to payment_attendee_registration_path(@attendee_registration)
        end
      rescue Stripe::StripeError => e
        flash[:alert] = "There was an error processing your payment: #{e.message}"
        redirect_to payment_attendee_registration_path(@attendee_registration)
      end
    end
  end

  private

  def set_stripe_key
    Stripe.api_key = ENV["STRIPE_API_KEY"] if ENV["STRIPE_API_KEY"].present?
  end

  def check_stripe_configured
    unless ENV["STRIPE_API_KEY"].present? && ENV["STRIPE_PUBLISHABLE_KEY"].present?
      Rails.logger.error "Stripe configuration missing. STRIPE_API_KEY present: #{ENV['STRIPE_API_KEY'].present?}, STRIPE_PUBLISHABLE_KEY present: #{ENV['STRIPE_PUBLISHABLE_KEY'].present?}"
      flash[:alert] = "Payment system is not configured. Please ensure STRIPE_API_KEY and STRIPE_PUBLISHABLE_KEY are set in your .env file and restart the server."
      redirect_to root_path
    end
  end

  def attendee_registration_params
    params.require(:attendee_registration).permit(
      :terms_agreement,
      :medical_consent,
      :guardian_1_name,
      :guardian_1_email,
      :guardian_1_phone,
      :guardian_1_address_line_1,
      :guardian_1_address_line_2,
      :guardian_1_city,
      :guardian_1_state,
      :guardian_1_zip,
      :guardian_2_name,
      :guardian_2_email,
      :guardian_2_phone,
      :guardian_2_same_address,
      :guardian_2_address_line_1,
      :guardian_2_address_line_2,
      :guardian_2_city,
      :guardian_2_state,
      :guardian_2_zip,
      :emergency_contact_1_name,
      :emergency_contact_1_phone,
      :emergency_contact_2_name,
      :emergency_contact_2_phone,
      :interest_in_counselling,
      attendees_attributes: [
        :id,
        :first_name,
        :last_name,
        :date_of_birth,
        :age,
        :gender,
        :ecclesia,
        :piano,
        :phone,
        :email,
        :address_line_1,
        :address_line_2,
        :city,
        :state,
        :zip,
        :tshirt_size,
        :medical_conditions,
        :dietary_restrictions,
        :allergies,
        :special_needs,
        :notes,
        :_destroy
      ]
    )
  end
end
