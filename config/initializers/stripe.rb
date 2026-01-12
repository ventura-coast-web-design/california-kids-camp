# frozen_string_literal: true

require 'stripe'

# Set Stripe API key from environment variable
Stripe.api_key = ENV['STRIPE_API_KEY'] if ENV['STRIPE_API_KEY'].present?

