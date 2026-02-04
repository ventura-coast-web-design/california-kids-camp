# frozen_string_literal: true

class RegistrationMailer < ApplicationMailer
  default from: "noreply@californiacamping.com"

  # Send confirmation email for attendee registration
  def attendee_registration_confirmation(attendee_registration)
    @attendee_registration = attendee_registration
    @guardian_email = attendee_registration.guardian_1_email
    @guardian_name = attendee_registration.guardian_1_name

    mail(
      to: @guardian_email,
      subject: "Registration Confirmation - California Kids Camp"
    )
  end

  # Send confirmation email for counsellor registration
  def counsellor_registration_confirmation(counsellor)
    @counsellor = counsellor
    @counsellor_email = counsellor.email
    @counsellor_name = "#{counsellor.first_name} #{counsellor.last_name}"

    mail(
      to: @counsellor_email,
      subject: "Registration Confirmation - California Kids Camp"
    )
  end
end
