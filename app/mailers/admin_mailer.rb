# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  default from: "kidscampcalifornia@gmail.com"

  def login_code(code)
    @otp_code = code
    @expiry_minutes = (User::OTP_EXPIRY_TIME / 60).to_i

    mail(
      to: ENV.fetch("ADMIN_OTP_EMAIL", "kidscampcalifornia@gmail.com"),
      subject: "Admin login verification code — Kids Camp California"
    )
  end
end
