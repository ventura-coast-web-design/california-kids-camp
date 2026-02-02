# frozen_string_literal: true

class Donation < ApplicationRecord
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 5.0 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :stripe_payment_intent_id, uniqueness: true, allow_nil: true

  scope :succeeded, -> { where(payment_status: "succeeded") }
  scope :pending, -> { where(payment_status: "pending") }

  def succeeded?
    payment_status == "succeeded"
  end

  def pending?
    payment_status == "pending"
  end
end
