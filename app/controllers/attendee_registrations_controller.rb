# frozen_string_literal: true

class AttendeeRegistrationsController < ApplicationController
  # Set Stripe API key
  before_action :set_stripe_key
  before_action :check_stripe_configured, only: [ :payment, :create_payment_intent ]
  before_action :cleanup_old_pending_registrations, only: [ :payment ]

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
    @attendee_registration.payment_status = "pending"

    # Clean up any old pending registration from this session before creating a new one
    old_registration_data = session[:pending_registration]
    if old_registration_data
      old_registration_id = old_registration_data[:id] || old_registration_data["id"]
      if old_registration_id.present?
        old_registration = AttendeeRegistration.find_by(id: old_registration_id)
        if old_registration && old_registration.payment_status == "pending"
          # Cancel any associated payment intents
          if old_registration.stripe_payment_intent_id.present?
            begin
              old_payment_intent = Stripe::PaymentIntent.retrieve(old_registration.stripe_payment_intent_id)
              if [ "requires_payment_method", "requires_confirmation" ].include?(old_payment_intent.status)
                Stripe::PaymentIntent.cancel(old_registration.stripe_payment_intent_id)
              end
            rescue Stripe::StripeError => e
              Rails.logger.warn "Failed to cancel old payment intent #{old_registration.stripe_payment_intent_id}: #{e.message}"
            end
          end
          # Delete the old pending registration
          old_registration.destroy
        end
      end
    end

    # Save registration to database immediately to avoid cookie overflow
    if @attendee_registration.save
      # Store only the registration ID in session (much smaller than full data)
      session[:pending_registration] = {
        "id" => @attendee_registration.id.to_s
      }

      redirect_to payment_attendee_registration_path(@attendee_registration)
    else
      flash.now[:alert] = "There was an error with your registration. Please check the form and try again."
      render :new, status: :unprocessable_entity
    end
  end

  # GET /attendee_registrations/:id/payment
  def payment
    registration_id = params[:id]
    registration_data = session[:pending_registration]

    # Load registration from database
    @attendee_registration = AttendeeRegistration.find_by(id: registration_id)
    
    if @attendee_registration.nil?
      flash[:alert] = "Registration not found or expired. Please start over."
      redirect_to new_attendee_path
      return
    end

    # Verify this registration belongs to the current session (security check)
    session_reg_id = registration_data&.dig(:id) || registration_data&.dig("id")
    if session_reg_id != registration_id.to_s
      # Registration doesn't belong to this session - delete it if it's still pending
      if @attendee_registration.payment_status == "pending"
        @attendee_registration.destroy
      end
      flash[:alert] = "Registration session expired. Please start over."
      redirect_to new_attendee_path
      return
    end

    # Check if already paid
    if @attendee_registration.paid?
      flash[:notice] = "Payment already completed for this registration."
      redirect_to attendee_registration_path(@attendee_registration)
      return
    end

    # Ensure payment_status is pending
    @attendee_registration.update(payment_status: "pending") unless @attendee_registration.payment_status == "pending"

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
    registration_id = params[:id]
    registration_data = session[:pending_registration]

    # Load registration from database
    @attendee_registration = AttendeeRegistration.find_by(id: registration_id)
    
    unless @attendee_registration
      render json: { error: "Registration not found or expired." }, status: :unprocessable_entity
      return
    end

    # Verify this registration belongs to the current session (security check)
    session_reg_id = registration_data&.dig(:id) || registration_data&.dig("id")
    if session_reg_id != registration_id.to_s
      # Registration doesn't belong to this session - delete it if it's still pending
      if @attendee_registration.payment_status == "pending"
        @attendee_registration.destroy
      end
      render json: { error: "Registration session expired. Please start over." }, status: :unprocessable_entity
      return
    end

    # Check if registration is still pending (shouldn't happen, but safety check)
    unless @attendee_registration.payment_status == "pending"
      render json: { error: "Registration is no longer pending payment." }, status: :unprocessable_entity
      return
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

      # Check if payment intent already exists for this registration
      if @attendee_registration.stripe_payment_intent_id.present?
        payment_intent = Stripe::PaymentIntent.retrieve(@attendee_registration.stripe_payment_intent_id)

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
          attendee_registration_id: @attendee_registration.id,
          guardian_email: @attendee_registration.guardian_1_email,
          payment_type: payment_type
        }
      )

      # Store payment intent ID in database
      @attendee_registration.update(
        stripe_payment_intent_id: payment_intent.id,
        payment_type: payment_type
      )

      render json: {
        clientSecret: payment_intent.client_secret
      }
    rescue Stripe::StripeError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  # POST /attendee_registrations/:id/payment_success
  def payment_success
    registration_id = params[:id]
    registration_data = session[:pending_registration]
    payment_intent_id = params[:payment_intent_id]

    # Load registration from database
    @attendee_registration = AttendeeRegistration.find_by(id: registration_id)
    
    unless @attendee_registration
      flash[:alert] = "Registration not found or expired. Please start over."
      redirect_to new_attendee_path
      return
    end

    # Verify this registration belongs to the current session (security check)
    session_reg_id = registration_data&.dig(:id) || registration_data&.dig("id")
    if session_reg_id != registration_id.to_s
      # Registration doesn't belong to this session - delete it if it's still pending
      if @attendee_registration.payment_status == "pending"
        @attendee_registration.destroy
      end
      flash[:alert] = "Registration session expired. Please start over."
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

        # Clear session data
        session.delete(:pending_registration)

        # Send confirmation email
        RegistrationMailer.attendee_registration_confirmation(@attendee_registration).deliver_later

        redirect_to attendee_registration_path(@attendee_registration)
      else
        # Payment failed - delete the pending registration
        flash[:alert] = "Payment was not successful. Please try again."
        @attendee_registration.destroy
        session.delete(:pending_registration)
        redirect_to new_attendee_path
      end
    rescue Stripe::StripeError => e
      # Payment error - delete the pending registration
      flash[:alert] = "There was an error processing your payment: #{e.message}"
      @attendee_registration.destroy
      session.delete(:pending_registration)
      redirect_to new_attendee_path
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

  # Clean up old pending registrations that were never paid (older than 1 hour)
  def cleanup_old_pending_registrations
    old_pending = AttendeeRegistration.where(payment_status: "pending")
                                      .where("created_at < ?", 1.hour.ago)
    
    old_pending.find_each do |registration|
      # Cancel any associated payment intents
      if registration.stripe_payment_intent_id.present?
        begin
          payment_intent = Stripe::PaymentIntent.retrieve(registration.stripe_payment_intent_id)
          if [ "requires_payment_method", "requires_confirmation" ].include?(payment_intent.status)
            Stripe::PaymentIntent.cancel(registration.stripe_payment_intent_id)
          end
        rescue Stripe::StripeError => e
          Rails.logger.warn "Failed to cancel payment intent #{registration.stripe_payment_intent_id}: #{e.message}"
        end
      end
      
      # Delete the registration
      registration.destroy
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
