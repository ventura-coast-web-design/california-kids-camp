# frozen_string_literal: true

class CounsellorsController < ApplicationController
  # GET /counsellors/register
  def new
    @counsellors = [ Counsellor.new ] # Start with one counselor form
  end

  # GET /counsellors/:id
  def show
    @counsellor = Counsellor.find(params[:id])
  end

  # POST /counsellors
  def create
    counselors_data = params[:counsellors]
    return redirect_to new_counsellor_path, alert: "No counselor data submitted." unless counselors_data.present?
    
    # Convert ActionController::Parameters hash to array, sorted by numeric index
    # When form submits counsellors[0][first_name], Rails creates a hash with string keys "0", "1", etc.
    # Convert to hash first to ensure consistent access, then convert back to Parameters for each counselor
    counselors_hash = counselors_data.to_unsafe_h
    keys = counselors_hash.is_a?(Hash) ? counselors_hash.keys.sort_by(&:to_i) : []
    counselors_array = if counselors_hash.is_a?(Hash)
                         # Get all keys, sort numerically, and map to their values
                         keys.map { |key| ActionController::Parameters.new(counselors_hash[key]) }.compact
                       else
                         Array(counselors_data).compact
                       end
    
    return redirect_to new_counsellor_path, alert: "No counselor data found." if counselors_array.empty?
    
    created_counselors = []
    errors = []

    # Create all counselors
    counselors_array.each_with_index do |counsellor_data, index|
      next unless counsellor_data.present?
      
      # Extract squirts data from original hash before wrapping in Parameters
      # This ensures we can access nested hash data properly
      original_key = keys[index]
      original_counsellor_hash = counselors_hash[original_key] if original_key
      squirts_data = if original_counsellor_hash.is_a?(Hash)
                       original_counsellor_hash["squirts"] || original_counsellor_hash[:squirts]
                     elsif original_counsellor_hash.is_a?(ActionController::Parameters)
                       original_counsellor_hash[:squirts] || original_counsellor_hash["squirts"]
                     end
      
      permitted_params = counsellor_params_for(counsellor_data)
      counsellor = Counsellor.new(permitted_params)

      # Handle squirts (format: "name|gender|age,name|gender|age")
      if squirts_data.present?
        # Convert to hash if it's ActionController::Parameters
        squirts_hash = squirts_data.is_a?(ActionController::Parameters) ? squirts_data.to_unsafe_h : squirts_data
        if squirts_hash.is_a?(Hash) && squirts_hash.any?
          squirts_array = []
          squirts_hash.each do |_key, squirt|
            next unless squirt.is_a?(Hash) || squirt.is_a?(ActionController::Parameters)
            # Convert to hash if needed
            squirt_hash = squirt.is_a?(ActionController::Parameters) ? squirt.to_unsafe_h : squirt
            # Handle both symbol and string keys
            name = (squirt_hash[:name] || squirt_hash["name"]).to_s.strip
            next if name.blank?
            gender = (squirt_hash[:gender] || squirt_hash["gender"]).to_s.strip
            age = (squirt_hash[:age] || squirt_hash["age"]).to_s.strip
            squirts_array << "#{name}|#{gender}|#{age}" if name.present?
          end
          counsellor.squirts = squirts_array.join(",") if squirts_array.any?
        end
      end

      # Handle pairing requests
      # If requested_pairing_with is present, it came from the dropdown (registered together)
      # If only requested_pairing_name is present, it was manually typed (requested)
      if counsellor_data[:requested_pairing_with].present?
        # Came from dropdown - save name and keep requested_pairing_with as flag
        counsellor.requested_pairing_name = counsellor_data[:requested_pairing_with].to_s.strip
        counsellor.requested_pairing_with = counsellor_data[:requested_pairing_with].to_s.strip # Keep as flag
      elsif counsellor_data[:requested_pairing_name].present?
        # Manually typed - save name and clear requested_pairing_with
        counsellor.requested_pairing_name = counsellor_data[:requested_pairing_name].to_s.strip
        counsellor.requested_pairing_with = nil
      end

      if counsellor.save
        created_counselors << counsellor
      else
        errors.concat(counsellor.errors.full_messages.map { |msg| "Counselor #{index + 1}: #{msg}" })
      end
    end

    if errors.empty? && created_counselors.any?
      # Send confirmation emails to all registered counselors
      created_counselors.each do |counsellor|
        RegistrationMailer.counsellor_registration_confirmation(counsellor).deliver_later
      end

      # Store count of registered counselors in flash for display on confirmation page
      flash[:notice] = "Registration submitted successfully! We'll be in touch soon."
      flash[:counsellors_count] = created_counselors.count if created_counselors.count > 1
      redirect_to counsellor_path(created_counselors.first)
    else
      @counsellors = counselors_array.map { |data| Counsellor.new(counsellor_params_for(data)) }
      @counsellors = [ Counsellor.new ] if @counsellors.empty?
      flash.now[:alert] = errors.any? ? errors.join(", ") : "There was an error with your registration. Please check the form and try again."
      render :new, status: :unprocessable_entity
    end
  end

  private

  def counsellor_params_for(data)
    return {} unless data.present?
    
    # Handle both ActionController::Parameters and Hash
    if data.respond_to?(:permit)
      data.permit(
        :first_name, :last_name, :gender,
        :address_line_1, :city,
        :state_province_region, :postal_code,
        :country, :phone, :email,
        :ecclesia, :tshirt_size, :piano,
        :requested_pairing_name,
        :requested_pairing_with
      )
    elsif data.is_a?(Hash)
      ActionController::Parameters.new(data).permit(
        :first_name, :last_name, :gender,
        :address_line_1, :city,
        :state_province_region, :postal_code,
        :country, :phone, :email,
        :ecclesia, :tshirt_size, :piano,
        :requested_pairing_name,
        :requested_pairing_with
      )
    else
      {}
    end
  end
end
