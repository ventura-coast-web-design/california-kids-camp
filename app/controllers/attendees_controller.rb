# frozen_string_literal: true

class AttendeesController < ApplicationController
  skip_before_action :check_otp_requirement, only: [ :new, :create ]

  # GET /attendees/register
  def new
    @attendee = Attendee.new
  end

  # POST /attendees
  def create
    @attendee = Attendee.new(attendee_params)

    if @attendee.save
      flash[:notice] = "Registration submitted successfully! We'll be in touch soon."
      redirect_to root_path
    else
      flash.now[:alert] = "There was an error with your registration. Please check the form and try again."
      render :new, status: :unprocessable_entity
    end
  end

  private

  def attendee_params
    # Add your permitted parameters here once you've added fields to the migration
    # Example: params.require(:attendee).permit(:name, :age, :ecclesia, :parent_name, :parent_email, :parent_phone)
    params.require(:attendee).permit()
  end
end
