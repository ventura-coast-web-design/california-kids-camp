# frozen_string_literal: true

class AttendeeRegistrationsController < ApplicationController
  # Set Stripe API key
  before_action :set_stripe_key
  before_action :check_stripe_configured, only: [:payment, :create_payment_intent]

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
      return
    end
  end

  # POST /attendee_registrations
  def create
    @attendee_registration = AttendeeRegistration.new(attendee_registration_params)
    @attendee_registration.payment_status = 'pending'
    @attendee_registration.amount_paid = @attendee_registration.calculate_total_amount

    if @attendee_registration.save
      redirect_to payment_attendee_registration_path(@attendee_registration)
    else
      flash.now[:alert] = "There was an error with your registration. Please check the form and try again."
      render :new, status: :unprocessable_entity
    end
  end

  # GET /attendee_registrations/:id/payment
  def payment
    @attendee_registration = AttendeeRegistration.find(params[:id])
    
    # Redirect if payment already completed
    if @attendee_registration.paid?
      flash[:notice] = "Payment already completed for this registration."
      redirect_to root_path
      return
    end
    
    # Check if Stripe is configured
    unless ENV['STRIPE_API_KEY'].present? && ENV['STRIPE_PUBLISHABLE_KEY'].present?
      Rails.logger.error "Stripe configuration missing. STRIPE_API_KEY present: #{ENV['STRIPE_API_KEY'].present?}, STRIPE_PUBLISHABLE_KEY present: #{ENV['STRIPE_PUBLISHABLE_KEY'].present?}"
      flash[:alert] = "Payment system is not configured. Please ensure STRIPE_API_KEY and STRIPE_PUBLISHABLE_KEY are set in your .env file and restart the server."
      redirect_to root_path
      return
    end
    
    @amount = @attendee_registration.calculate_total_amount
    @child_count = @attendee_registration.attendees.count
    @stripe_publishable_key = ENV['STRIPE_PUBLISHABLE_KEY']
  end

  # POST /attendee_registrations/:id/create_payment_intent
  def create_payment_intent
    @attendee_registration = AttendeeRegistration.find(params[:id])
    
    begin
      # Check if payment intent already exists and is still valid
      if @attendee_registration.stripe_payment_intent_id.present?
        payment_intent = Stripe::PaymentIntent.retrieve(@attendee_registration.stripe_payment_intent_id)
        
        # If payment intent is still in a processable state, reuse it
        if ['requires_payment_method', 'requires_confirmation'].include?(payment_intent.status)
          render json: {
            clientSecret: payment_intent.client_secret
          }
          return
        end
      end
      
      # Create new payment intent
      payment_intent = Stripe::PaymentIntent.create(
        amount: @attendee_registration.amount_in_cents,
        currency: 'usd',
        metadata: {
          attendee_registration_id: @attendee_registration.id,
          guardian_email: @attendee_registration.guardian_1_email
        }
      )

      @attendee_registration.update(stripe_payment_intent_id: payment_intent.id)
      
      render json: {
        clientSecret: payment_intent.client_secret
      }
    rescue Stripe::StripeError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  # POST /attendee_registrations/:id/payment_success
  def payment_success
    @attendee_registration = AttendeeRegistration.find(params[:id])
    payment_intent_id = params[:payment_intent_id] || @attendee_registration.stripe_payment_intent_id

    return redirect_to payment_attendee_registration_path(@attendee_registration) unless payment_intent_id

    begin
      payment_intent = Stripe::PaymentIntent.retrieve(payment_intent_id)
      
      # Verify this payment intent belongs to this registration
      unless payment_intent.metadata['attendee_registration_id'].to_i == @attendee_registration.id
        flash[:alert] = "Invalid payment. Please try again."
        redirect_to payment_attendee_registration_path(@attendee_registration)
        return
      end
      
      if payment_intent.status == 'succeeded'
        @attendee_registration.update(
          payment_status: 'succeeded',
          stripe_payment_intent_id: payment_intent_id,
          amount_paid: payment_intent.amount / 100.0
        )
        
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

  private

  def set_stripe_key
    Stripe.api_key = ENV['STRIPE_API_KEY'] if ENV['STRIPE_API_KEY'].present?
  end

  def check_stripe_configured
    unless ENV['STRIPE_API_KEY'].present? && ENV['STRIPE_PUBLISHABLE_KEY'].present?
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
      :notes,
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



