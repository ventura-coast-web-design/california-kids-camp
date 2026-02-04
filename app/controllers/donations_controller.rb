# frozen_string_literal: true

class DonationsController < ApplicationController
  # Set Stripe API key
  before_action :set_stripe_key
  before_action :check_stripe_configured, only: [ :show, :create_payment_intent ]
  before_action :set_donation, only: [ :payment_success, :confirmation ]

  # GET /donations
  def show
    @stripe_publishable_key = ENV["STRIPE_PUBLISHABLE_KEY"]
    @donation = Donation.new
  end

  # POST /donations/create_payment_intent
  def create_payment_intent
    amount = params[:amount].to_f

    # Validate minimum amount
    if amount < 5.0
      render json: { error: "Minimum donation amount is $5.00" }, status: :unprocessable_entity
      return
    end

    # Validate required fields
    unless params[:email].present? && params[:name].present?
      render json: { error: "Name and email are required" }, status: :unprocessable_entity
      return
    end

    begin
      amount_in_cents = (amount * 100).to_i

      # Create donation record
      donation = Donation.create!(
        amount: amount,
        email: params[:email].strip.downcase,
        name: params[:name].strip,
        payment_status: "pending"
      )

      # Create Stripe payment intent
      payment_intent = Stripe::PaymentIntent.create(
        amount: amount_in_cents,
        currency: "usd",
        metadata: {
          donation_id: donation.id,
          donor_email: donation.email,
          donor_name: donation.name
        }
      )

      donation.update(stripe_payment_intent_id: payment_intent.id)

      render json: {
        clientSecret: payment_intent.client_secret,
        donation_id: donation.id
      }
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.record.errors.full_messages.join(", ") }, status: :unprocessable_entity
    rescue Stripe::StripeError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  # POST /donations/:id/payment_success
  def payment_success
    payment_intent_id = params[:payment_intent_id] || @donation.stripe_payment_intent_id

    unless payment_intent_id
      flash[:alert] = "Payment intent not found."
      redirect_to donations_path
      return
    end

    begin
      payment_intent = Stripe::PaymentIntent.retrieve(payment_intent_id)

      # Verify this payment intent belongs to this donation
      unless payment_intent.metadata["donation_id"].to_i == @donation.id
        flash[:alert] = "Invalid payment. Please try again."
        redirect_to donations_path
        return
      end

      if payment_intent.status == "succeeded"
        # Check if payment was already processed (idempotency check)
        if @donation.succeeded? && @donation.stripe_payment_intent_id == payment_intent_id
          redirect_to donation_confirmation_path(@donation)
          return
        end

        # Update donation with successful payment
        @donation.update(
          payment_status: "succeeded",
          stripe_payment_intent_id: payment_intent_id,
          amount: payment_intent.amount / 100.0
        )

        # Send receipt email
        DonationMailer.donation_receipt(@donation).deliver_later

        redirect_to donation_confirmation_path(@donation)
      else
        flash[:alert] = "Payment was not successful. Please try again."
        redirect_to donations_path
      end
    rescue Stripe::StripeError => e
      flash[:alert] = "There was an error processing your payment: #{e.message}"
      redirect_to donations_path
    end
  end

  # GET /donations/:id/confirmation
  def confirmation
    unless @donation.succeeded?
      flash[:alert] = "Payment not completed."
      redirect_to donations_path
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

  def set_donation
    @donation = Donation.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Donation not found."
    redirect_to donations_path
  end
end
