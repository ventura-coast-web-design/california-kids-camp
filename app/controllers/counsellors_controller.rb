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
    params.require(:counsellor).permit(
      :counsellor_1_first_name, :counsellor_1_last_name,
      :counsellor_1_address_line_1, :counsellor_1_city,
      :counsellor_1_state_province_region, :counsellor_1_postal_code,
      :counsellor_1_country, :counsellor_1_phone, :counsellor_1_email,
      :counsellor_1_ecclesia, :counsellor_1_tshirt_size, :counsellor_1_piano,
      :counsellor_2_first_name, :counsellor_2_last_name,
      :counsellor_2_address_line_1, :counsellor_2_city,
      :counsellor_2_state_province_region, :counsellor_2_postal_code,
      :counsellor_2_country, :counsellor_2_phone, :counsellor_2_email,
      :counsellor_2_ecclesia, :counsellor_2_tshirt_size, :counsellor_2_piano
    )
  end
end




