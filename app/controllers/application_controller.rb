class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :check_otp_requirement

  private

  def check_otp_requirement
    return unless user_signed_in?
    return if controller_name == 'otp_sessions' # Don't redirect if already on OTP page
    return if devise_controller? && (controller_name == 'sessions' && action_name == 'destroy') # Allow sign out
    
    # If user has 2FA enabled and hasn't verified OTP this session
    if current_user.otp_required? && !session[:otp_verified]
      redirect_to users_otp_verify_path
    end
  end
end
