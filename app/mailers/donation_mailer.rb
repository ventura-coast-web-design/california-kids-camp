# frozen_string_literal: true

class DonationMailer < ApplicationMailer
  default from: "noreply@californiacamping.com"

  # Send receipt email for donation
  def donation_receipt(donation)
    @donation = donation
    @donor_email = donation.email
    @donor_name = donation.name
    @amount = donation.amount
    @payment_date = donation.created_at

    mail(
      to: @donor_email,
      subject: "Donation Receipt - California Kids Camp"
    )
  end
end
