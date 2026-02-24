# frozen_string_literal: true

require "csv"

class AdminController < ApplicationController
  before_action :require_admin_password, except: [ :login, :authenticate, :logout ]

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
    # GET request - show login form
    # If already authenticated, redirect to admin dashboard
    redirect_to admin_path if session[:admin_authenticated]
  end

  def authenticate
    password = params[:password]
    admin_password = ENV.fetch("ADMIN_PASSWORD", "CampArnaz2026")

    if password == admin_password
      session[:admin_authenticated] = true
      redirect_to admin_path, notice: "Successfully authenticated"
    else
      flash.now[:alert] = "Invalid password"
      render :login, status: :unauthorized
    end
  end

  def logout
    session[:admin_authenticated] = nil
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

  def require_admin_password
    unless session[:admin_authenticated]
      redirect_to admin_login_path, alert: "Please authenticate to access admin area"
    end
  end
end
