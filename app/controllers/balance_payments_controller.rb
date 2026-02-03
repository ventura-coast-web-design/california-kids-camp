# frozen_string_literal: true

class BalancePaymentsController < ApplicationController
  # Set Stripe API key
  before_action :set_stripe_key
  before_action :check_stripe_configured, only: [ :show, :create_payment_intent ]
  before_action :set_registration, only: [ :show, :create_payment_intent, :payment_success ]

  # GET /balance_payment/lookup
  def lookup
    # Render lookup form
  end

  # POST /balance_payment/lookup
  def find_registration
    email = params[:email]&.strip&.downcase

    unless email.present?
      flash[:alert] = "Please enter an email address."
      render :lookup, status: :unprocessable_entity
      return
    end

    # Find registration by primary guardian email (case-insensitive)
    @registration = AttendeeRegistration.includes(:attendees).find_by("LOWER(guardian_1_email) = ?", email)

    unless @registration
      flash[:alert] = "No registration found with that email address."
      render :lookup, status: :unprocessable_entity
      return
    end

    # Check if payment has been made
    unless @registration.paid?
      flash[:alert] = "This registration does not have any payment completed. Please complete your initial registration first."
      render :lookup, status: :unprocessable_entity
      return
    end

    # Check if there's a remaining balance
    remaining = @registration.remaining_balance

    if remaining.nil? || remaining <= 0
      flash[:notice] = "This registration is already paid in full."
      render :lookup, status: :unprocessable_entity
      return
    end

    # Redirect to balance payment page
    redirect_to balance_payment_path(@registration)
  end

  # GET /balance_payment/:id
  def show
    # Check if payment has been made
    unless @registration.paid?
      flash[:alert] = "This registration does not have any payment completed."
      redirect_to balance_payment_lookup_path
      return
    end

    # Check if there's a remaining balance
    @remaining_balance = @registration.remaining_balance

    if @remaining_balance.nil? || @remaining_balance <= 0
      flash[:notice] = "This registration is already paid in full."
      redirect_to balance_payment_lookup_path
      return
    end

    @stripe_publishable_key = ENV["STRIPE_PUBLISHABLE_KEY"]
  end

  # POST /balance_payment/:id/create_payment_intent
  def create_payment_intent
    # Verify there's a remaining balance
    remaining = @registration.remaining_balance
    if remaining <= 0
      render json: { error: "No remaining balance to pay." }, status: :unprocessable_entity
      return
    end

    begin
      amount_in_cents = (remaining * 100).to_i

      # Check if payment intent already exists
      if @registration.stripe_payment_intent_id.present?
        payment_intent = Stripe::PaymentIntent.retrieve(@registration.stripe_payment_intent_id)

        # If payment intent is still in a processable state and matches the remaining balance, reuse it
        if [ "requires_payment_method", "requires_confirmation" ].include?(payment_intent.status) &&
           payment_intent.amount == amount_in_cents &&
           payment_intent.metadata["payment_type"] == "balance"
          render json: {
            clientSecret: payment_intent.client_secret
          }
          return
        end
      end

      # Create new payment intent for balance payment
      payment_intent = Stripe::PaymentIntent.create(
        amount: amount_in_cents,
        currency: "usd",
        metadata: {
          attendee_registration_id: @registration.id,
          guardian_email: @registration.guardian_1_email,
          payment_type: "balance"
        }
      )

      @registration.update(
        stripe_payment_intent_id: payment_intent.id
      )

      render json: {
        clientSecret: payment_intent.client_secret
      }
    rescue Stripe::StripeError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  # POST /balance_payment/:id/payment_success
  def payment_success
    payment_intent_id = params[:payment_intent_id] || @registration.stripe_payment_intent_id

    unless payment_intent_id
      flash[:alert] = "Payment intent not found."
      redirect_to balance_payment_path(@registration)
      return
    end

    begin
      payment_intent = Stripe::PaymentIntent.retrieve(payment_intent_id)

      # Verify this payment intent belongs to this registration
      unless payment_intent.metadata["attendee_registration_id"].to_i == @registration.id &&
             payment_intent.metadata["payment_type"] == "balance"
        flash[:alert] = "Invalid payment. Please try again."
        redirect_to balance_payment_path(@registration)
        return
      end

      if payment_intent.status == "succeeded"
        # Check if payment was already processed (idempotency check)
        if @registration.payment_status == "succeeded" &&
           @registration.stripe_payment_intent_id == payment_intent_id &&
           @registration.remaining_balance <= 0
          redirect_to balance_payment_confirmation_path(@registration)
          return
        end

        # Update registration with additional payment
        new_amount_paid = (@registration.amount_paid.to_f + (payment_intent.amount / 100.0)).round(2)

        @registration.update(
          payment_status: "succeeded",
          stripe_payment_intent_id: payment_intent_id,
          amount_paid: new_amount_paid
        )

        redirect_to balance_payment_confirmation_path(@registration)
      else
        flash[:alert] = "Payment was not successful. Please try again."
        redirect_to balance_payment_path(@registration)
      end
    rescue Stripe::StripeError => e
      flash[:alert] = "There was an error processing your payment: #{e.message}"
      redirect_to balance_payment_path(@registration)
    end
  end

  # GET /balance_payment/:id/confirmation
  def confirmation
    @registration = AttendeeRegistration.find(params[:id])

    unless @registration.paid_in_full?
      flash[:alert] = "Payment not completed."
      redirect_to balance_payment_path(@registration)
      nil
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

  def set_registration
    @registration = AttendeeRegistration.includes(:attendees).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Registration not found."
    redirect_to balance_payment_lookup_path
  end
end
