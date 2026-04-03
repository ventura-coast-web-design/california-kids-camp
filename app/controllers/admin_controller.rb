# frozen_string_literal: true

require "csv"

class AdminController < ApplicationController
  before_action :require_admin_password, except: [
    :login, :authenticate, :logout,
    :verify_otp, :submit_verify_otp, :resend_otp, :cancel_otp
  ]

  def index
    @attendees = Attendee.includes(:attendee_registration).where(archived: false).order(created_at: :desc)
    @counsellors = Counsellor.where(archived: false).order(created_at: :desc)
    @archived_attendees = Attendee.includes(:attendee_registration).where(archived: true).order(created_at: :desc)
    @archived_counsellors = Counsellor.where(archived: true).order(created_at: :desc)
  end

  def export_attendees
    @attendees = Attendee.includes(:attendee_registration).where(archived: false).order(created_at: :desc)

    csv_data = CSV.generate do |csv|
      # Header row
      csv << [
        "Name",
        "Payment Status",
        "Amount Paid",
        "Remaining Balance",
        "Date of Birth",
        "Age",
        "Gender",
        "Phone",
        "Email",
        "T-Shirt Size",
        "Ecclesia",
        "Piano",
        "Address Line 1",
        "Address Line 2",
        "City",
        "State",
        "Zip",
        "Medical Conditions",
        "Dietary Restrictions",
        "Allergies",
        "Special Needs",
        "Notes",
        "Guardian 1 Name",
        "Guardian 1 Email",
        "Guardian 1 Phone",
        "Guardian 1 Address Line 1",
        "Guardian 1 Address Line 2",
        "Guardian 1 City",
        "Guardian 1 State",
        "Guardian 1 Zip",
        "Guardian 2 Name",
        "Guardian 2 Email",
        "Guardian 2 Phone",
        "Guardian 2 Address Line 1",
        "Guardian 2 Address Line 2",
        "Guardian 2 City",
        "Guardian 2 State",
        "Guardian 2 Zip",
        "Emergency Contact 1 Name",
        "Emergency Contact 1 Phone",
        "Emergency Contact 2 Name",
        "Emergency Contact 2 Phone",
        "Registration Date"
      ]

      # Data rows
      @attendees.each do |attendee|
        registration = attendee.attendee_registration
        payment_status = registration.payment_status_display

        csv << [
          "#{attendee.first_name} #{attendee.last_name}",
          payment_status,
          registration.calculate_per_attendee_paid,
          registration.calculate_per_attendee_balance,
          attendee.date_of_birth&.strftime("%m/%d/%Y"),
          attendee.age,
          attendee.gender,
          attendee.phone,
          attendee.email,
          attendee.tshirt_size,
          attendee.ecclesia,
          attendee.piano ? "Yes" : "No",
          attendee.address_line_1,
          attendee.address_line_2,
          attendee.city,
          attendee.state,
          attendee.zip,
          attendee.medical_conditions,
          attendee.dietary_restrictions,
          attendee.allergies,
          attendee.special_needs,
          attendee.notes,
          registration.guardian_1_name,
          registration.guardian_1_email,
          registration.guardian_1_phone,
          registration.guardian_1_address_line_1,
          registration.guardian_1_address_line_2,
          registration.guardian_1_city,
          registration.guardian_1_state,
          registration.guardian_1_zip,
          registration.guardian_2_name,
          registration.guardian_2_email,
          registration.guardian_2_phone,
          registration.guardian_2_same_address ? "Same as Guardian 1" : registration.guardian_2_address_line_1,
          registration.guardian_2_same_address ? "" : registration.guardian_2_address_line_2,
          registration.guardian_2_same_address ? "" : registration.guardian_2_city,
          registration.guardian_2_same_address ? "" : registration.guardian_2_state,
          registration.guardian_2_same_address ? "" : registration.guardian_2_zip,
          registration.emergency_contact_1_name,
          registration.emergency_contact_1_phone,
          registration.emergency_contact_2_name,
          registration.emergency_contact_2_phone,
          registration.created_at.in_time_zone("Pacific Time (US & Canada)").strftime("%m/%d/%Y")
        ]
      end
    end

    respond_to do |format|
      format.csv do
        send_data csv_data,
          filename: "attendees_#{Date.current.strftime('%Y%m%d')}.csv",
          type: "text/csv"
      end
    end
  end

  def export_counsellors
    @counsellors = Counsellor.where(archived: false).order(created_at: :desc)

    csv_data = CSV.generate do |csv|
      # Header row
      csv << [
        "Registration Date",
        "Registration Time",
        "First Name",
        "Last Name",
        "Gender",
        "Address Line 1",
        "City",
        "State/Province/Region",
        "Postal Code",
        "Country",
        "Phone",
        "Email",
        "Ecclesia",
        "T-Shirt Size",
        "Piano",
        "Pairing Request Name",
        "Requested Pairing With",
        "Squirts"
      ]

      # Data rows - each counsellor is a separate record
      @counsellors.each do |counsellor|
        csv << [
          counsellor.created_at.in_time_zone("Pacific Time (US & Canada)").strftime("%m/%d/%Y"),
          counsellor.created_at.in_time_zone("Pacific Time (US & Canada)").strftime("%I:%M %p %Z"),
          counsellor.first_name,
          counsellor.last_name,
          counsellor.gender,
          counsellor.address_line_1,
          counsellor.city,
          counsellor.state_province_region,
          counsellor.postal_code,
          counsellor.country,
          counsellor.phone,
          counsellor.email,
          counsellor.ecclesia,
          counsellor.tshirt_size,
          counsellor.piano,
          counsellor.requested_pairing_name,
          counsellor.requested_pairing_with,
          counsellor.squirts
        ]
      end
    end

    respond_to do |format|
      format.csv do
        send_data csv_data,
          filename: "counsellors_#{Date.current.strftime('%Y%m%d')}.csv",
          type: "text/csv"
      end
    end
  end

  def login
    return redirect_to admin_path if session[:admin_authenticated]
    redirect_to admin_verify_otp_path if session[:admin_otp_pending]
  end

  def authenticate
    password = params[:password]
    admin_password = ENV.fetch("ADMIN_PASSWORD", "CampArnaz2026")

    if password == admin_password
      session[:admin_otp_pending] = true
      code = generate_and_store_admin_otp
      begin
        AdminMailer.login_code(code).deliver_now
        redirect_to admin_verify_otp_path,
          notice: "A verification code was sent to the admin inbox. Enter it below to continue."
      rescue StandardError => e
        Rails.logger.error("Admin OTP email failed: #{e.class}: #{e.message}")
        clear_admin_otp_session
        flash[:alert] = "Could not send the verification email. Try again later or check mail settings."
        redirect_to admin_login_path
      end
    else
      flash.now[:alert] = "Invalid password"
      render :login, status: :unauthorized
    end
  end

  def verify_otp
    unless session[:admin_otp_pending]
      redirect_to admin_login_path, alert: "Please sign in with the admin password first."
      return
    end
    if admin_otp_expired?
      clear_admin_otp_session
      redirect_to admin_login_path, alert: "That code has expired. Please sign in again."
      return
    end
    @admin_otp_email = admin_otp_email
  end

  def submit_verify_otp
    unless session[:admin_otp_pending]
      redirect_to admin_login_path, alert: "Please sign in with the admin password first."
      return
    end
    if admin_otp_expired?
      clear_admin_otp_session
      redirect_to admin_login_path, alert: "That code has expired. Please sign in again."
      return
    end
    code = params[:otp_code].to_s.gsub(/\s+/, "")
    if verify_admin_otp_submitted(code)
      clear_admin_otp_session
      session[:admin_authenticated] = true
      redirect_to admin_path, notice: "Successfully authenticated"
    else
      @admin_otp_email = admin_otp_email
      flash.now[:alert] = "Invalid verification code. Try again or request a new code."
      render :verify_otp, status: :unprocessable_entity
    end
  end

  def resend_otp
    unless session[:admin_otp_pending]
      redirect_to admin_login_path, alert: "Please sign in with the admin password first."
      return
    end
    last = session[:admin_otp_last_resend_at]
    if last.present? && Time.at(last) > 1.minute.ago
      redirect_to admin_verify_otp_path, alert: "Please wait a minute before requesting another code."
      return
    end
    code = generate_and_store_admin_otp
    session[:admin_otp_last_resend_at] = Time.current.to_i
    begin
      AdminMailer.login_code(code).deliver_now
      redirect_to admin_verify_otp_path, notice: "A new verification code was sent to #{admin_otp_email}."
    rescue StandardError => e
      Rails.logger.error("Admin OTP resend failed: #{e.class}: #{e.message}")
      redirect_to admin_verify_otp_path, alert: "Could not send the email. Try again in a moment."
    end
  end

  def cancel_otp
    clear_admin_otp_session
    redirect_to admin_login_path, notice: "Sign-in cancelled."
  end

  def logout
    session[:admin_authenticated] = nil
    clear_admin_otp_session
    redirect_to admin_login_path, notice: "Logged out successfully"
  end

  def show_attendee
    @attendee = Attendee.includes(:attendee_registration).find(params[:id])
    @registration = @attendee.attendee_registration
  end

  def show_counsellor
    @counsellor = Counsellor.find(params[:id])
  end

  def archive_attendee
    @attendee = Attendee.includes(:attendee_registration).find(params[:id])
    attendee_name = "#{@attendee.first_name} #{@attendee.last_name}"

    if @attendee.update(archived: true)
      flash[:notice] = "Attendee #{attendee_name} has been archived successfully."
      redirect_to admin_path
    else
      flash[:alert] = "Failed to archive attendee: #{@attendee.errors.full_messages.join(', ')}"
      redirect_to admin_attendee_path(@attendee)
    end
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Attendee not found."
    redirect_to admin_path
  end

  def unarchive_attendee
    @attendee = Attendee.includes(:attendee_registration).find(params[:id])
    attendee_name = "#{@attendee.first_name} #{@attendee.last_name}"

    if @attendee.update_column(:archived, false)
      flash[:notice] = "Attendee #{attendee_name} has been restored from archive."
      redirect_to admin_path, status: :see_other
    else
      flash[:alert] = "Failed to unarchive attendee."
      redirect_to admin_path, status: :see_other
    end
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Attendee not found."
    redirect_to admin_path, status: :see_other
  end

  def delete_attendee
    @attendee = Attendee.includes(:attendee_registration).find(params[:id])

    # Only allow deletion of archived records
    unless @attendee.archived?
      flash[:alert] = "Only archived attendees can be permanently deleted. Please archive the attendee first."
      redirect_to admin_path
      return
    end

    @registration = @attendee.attendee_registration

    # Get accurate attendee count
    attendee_count = @registration.attendees.count

    # If this is the last attendee, delete the entire registration
    if attendee_count <= 1
      attendee_name = "#{@attendee.first_name} #{@attendee.last_name}"
      registration_id = @registration.id

      # Delete the attendee (which will cascade delete the registration due to dependent: :destroy)
      # But we need to delete the registration explicitly to handle payment cleanup
      if @attendee.destroy
        # Registration should be deleted via dependent: :destroy, but let's ensure it's gone
        AttendeeRegistration.find_by(id: registration_id)&.destroy

        flash[:notice] = "Attendee #{attendee_name} and their registration have been permanently deleted."
        redirect_to admin_path
      else
        flash[:alert] = "Failed to delete attendee: #{@attendee.errors.full_messages.join(', ')}"
        redirect_to admin_path
      end
      return
    end

    # Calculate per-attendee amount paid before deletion
    per_attendee_paid = @registration.calculate_per_attendee_paid

    # Delete the attendee
    attendee_name = "#{@attendee.first_name} #{@attendee.last_name}"

    if @attendee.destroy
      # Reload registration to get updated attendee count
      @registration.reload

      # Adjust amount_paid by subtracting the per-attendee amount
      # This ensures the payment amount reflects only the remaining attendees
      new_amount_paid = (@registration.amount_paid.to_f - per_attendee_paid).round(2)
      # Ensure amount_paid doesn't go negative
      new_amount_paid = [ new_amount_paid, 0.0 ].max

      @registration.update(amount_paid: new_amount_paid)

      flash[:notice] = "Attendee #{attendee_name} has been permanently deleted."
      redirect_to admin_path
    else
      flash[:alert] = "Failed to delete attendee: #{@attendee.errors.full_messages.join(', ')}"
      redirect_to admin_path
    end
  rescue ActiveRecord::RecordNotFound
    # Attendee was already deleted or doesn't exist
    flash[:notice] = "Attendee has been deleted."
    redirect_to admin_path
  end

  def archive_counsellor
    @counsellor = Counsellor.find(params[:id])
    counsellor_name = "#{@counsellor.first_name} #{@counsellor.last_name}"

    # Use update_column so we don't re-run validations (e.g. spam/legacy records may be invalid)
    if @counsellor.update_column(:archived, true)
      flash[:notice] = "Counselor #{counsellor_name} has been archived successfully."
      redirect_to admin_path, status: :see_other
    else
      flash[:alert] = "Failed to archive counselor."
      redirect_to admin_path, status: :see_other
    end
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Counselor not found."
    redirect_to admin_path, status: :see_other
  end

  def unarchive_counsellor
    @counsellor = Counsellor.find(params[:id])
    counsellor_name = "#{@counsellor.first_name} #{@counsellor.last_name}"

    if @counsellor.update_column(:archived, false)
      flash[:notice] = "Counselor #{counsellor_name} has been restored from archive."
      redirect_to admin_path, status: :see_other
    else
      flash[:alert] = "Failed to unarchive counselor."
      redirect_to admin_path, status: :see_other
    end
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Counselor not found."
    redirect_to admin_path, status: :see_other
  end

  def delete_counsellor
    @counsellor = Counsellor.find(params[:id])

    # Only allow deletion of archived records
    unless @counsellor.archived?
      flash[:alert] = "Only archived counselors can be permanently deleted. Please archive the counselor first."
      redirect_to admin_path
      return
    end

    counsellor_name = "#{@counsellor.first_name} #{@counsellor.last_name}"

    if @counsellor.destroy
      flash[:notice] = "Counselor #{counsellor_name} has been permanently deleted."
      redirect_to admin_path
    else
      flash[:alert] = "Failed to delete counselor: #{@counsellor.errors.full_messages.join(', ')}"
      redirect_to admin_path
    end
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Counselor not found."
    redirect_to admin_path
  end

  private

  def admin_otp_email
    ENV.fetch("ADMIN_OTP_EMAIL", "kidscampcalifornia@gmail.com")
  end

  def admin_otp_hmac_key_material
    "admin_login_otp/v1/#{Rails.application.secret_key_base}"
  end

  def generate_and_store_admin_otp
    code = rand(100_000..999_999).to_s
    digest = OpenSSL::HMAC.hexdigest("SHA256", admin_otp_hmac_key_material, code)
    session[:admin_otp_digest] = digest
    session[:admin_otp_sent_at] = Time.current.to_i
    code
  end

  def admin_otp_expired?
    sent = session[:admin_otp_sent_at]
    return true if sent.blank?

    Time.zone.at(sent) < User::OTP_EXPIRY_TIME.ago
  end

  def verify_admin_otp_submitted(code)
    return false if session[:admin_otp_digest].blank? || code.blank?
    return false if admin_otp_expired?

    expected = OpenSSL::HMAC.hexdigest("SHA256", admin_otp_hmac_key_material, code)
    ActiveSupport::SecurityUtils.secure_compare(session[:admin_otp_digest], expected)
  end

  def clear_admin_otp_session
    session.delete(:admin_otp_digest)
    session.delete(:admin_otp_sent_at)
    session.delete(:admin_otp_pending)
    session.delete(:admin_otp_last_resend_at)
  end

  def require_admin_password
    unless session[:admin_authenticated]
      redirect_to admin_login_path, alert: "Please authenticate to access admin area"
    end
  end
end
