# frozen_string_literal: true

class CounsellorsController < ApplicationController
  skip_before_action :check_otp_requirement, only: [ :new, :create ]

  # GET /counsellors/register
  def new
    @counsellor = Counsellor.new
  end

  # POST /counsellors
  def create
    @counsellor = Counsellor.new(counsellor_params)

    if @counsellor.save
      flash[:notice] = "Registration submitted successfully! We'll be in touch soon."
      redirect_to root_path
    else
      flash.now[:alert] = "There was an error with your registration. Please check the form and try again."
      render :new, status: :unprocessable_entity
    end
  end

  private

  def counsellor_params
    # Add your permitted parameters here once you've added fields to the migration
    # Example: params.require(:counsellor).permit(:name, :email, :phone, :ecclesia, :experience, :references)
    params.require(:counsellor).permit()
  end
end




