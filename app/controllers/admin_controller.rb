# frozen_string_literal: true

class AdminController < ApplicationController
  skip_before_action :check_otp_requirement

  before_action :require_admin_password, except: [ :login, :authenticate, :logout ]

  def index
    @attendees = Attendee.includes(:attendee_registration).order(created_at: :desc)
    @counsellors = Counsellor.order(created_at: :desc)
  end

  def login
    # GET request - show login form
    # If already authenticated, redirect to admin dashboard
    redirect_to admin_path if session[:admin_authenticated]
  end

  def authenticate
    password = params[:password]
    admin_password = ENV.fetch("ADMIN_PASSWORD", "test")

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

  private

  def require_admin_password
    unless session[:admin_authenticated]
      redirect_to admin_login_path, alert: "Please authenticate to access admin area"
    end
  end
end
