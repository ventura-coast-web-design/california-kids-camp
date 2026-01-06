# frozen_string_literal: true

class AttendeeRegistrationsController < ApplicationController
  # GET /attendees/register
  def new
    @attendee_registration = AttendeeRegistration.new
    # Start with one attendee form by default
    @attendee_registration.attendees.build
  end

  # POST /attendee_registrations
  def create
    @attendee_registration = AttendeeRegistration.new(attendee_registration_params)

    if @attendee_registration.save
      flash[:notice] = "Registration submitted successfully! We'll be in touch soon."
      redirect_to root_path
    else
      flash.now[:alert] = "There was an error with your registration. Please check the form and try again."
      render :new, status: :unprocessable_entity
    end
  end

  private

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



