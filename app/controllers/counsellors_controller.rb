# frozen_string_literal: true

class CounsellorsController < ApplicationController
  # GET /counsellors/register
  def new
    @counsellors = [ Counsellor.new ] # Start with one counselor form
  end

  # POST /counsellors
  def create
    counselors_data = params[:counsellors] || []
    created_counselors = []
    errors = []

    # Create all counselors
    counselors_data.each_with_index do |counsellor_data, index|
      counsellor = Counsellor.new(counsellor_params_for(counsellor_data))

      # Handle squirts (format: "name|gender|age,name|gender|age")
      if counsellor_data[:squirts].present? && counsellor_data[:squirts].is_a?(Hash)
        squirts_array = []
        counsellor_data[:squirts].each do |_key, squirt|
          next unless squirt.is_a?(Hash)
          next if squirt[:name].blank? || squirt[:name].to_s.strip.empty?
          name = squirt[:name].to_s.strip
          gender = squirt[:gender].to_s.strip
          age = squirt[:age].to_s.strip
          squirts_array << "#{name}|#{gender}|#{age}" if name.present?
        end
        counsellor.squirts = squirts_array.join(",") if squirts_array.any?
      end

      # Handle pairing requests
      # Store requested_pairing_with as comma-separated indices
      if counsellor_data[:requested_pairing_with].present?
        indices = Array(counsellor_data[:requested_pairing_with]).reject(&:blank?).map(&:to_i)
        counsellor.requested_pairing_with = indices.join(",") if indices.any?
      end

      if counsellor.save
        created_counselors << counsellor
      else
        errors.concat(counsellor.errors.full_messages.map { |msg| "Counselor #{index + 1}: #{msg}" })
      end
    end

    if errors.empty? && created_counselors.any?
      flash[:notice] = "Registration submitted successfully! We'll be in touch soon."
      redirect_to root_path
    else
      @counsellors = counselors_data.map { |data| Counsellor.new(counsellor_params_for(data)) }
      @counsellors = [ Counsellor.new ] if @counsellors.empty?
      flash.now[:alert] = errors.any? ? errors.join(", ") : "There was an error with your registration. Please check the form and try again."
      render :new, status: :unprocessable_entity
    end
  end

  private

  def counsellor_params_for(data)
    data.permit(
      :first_name, :last_name, :gender,
      :address_line_1, :city,
      :state_province_region, :postal_code,
      :country, :phone, :email,
      :ecclesia, :tshirt_size, :piano,
      :requested_pairing_name,
      requested_pairing_with: []
    )
  end
end
