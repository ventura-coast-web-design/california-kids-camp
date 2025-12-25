# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # OTP Configuration
  OTP_EXPIRY_TIME = 10.minutes
  OTP_LENGTH = 6

  # Validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  # OTP Methods
  def generate_otp
    # Generate a random 6-digit OTP
    otp = rand(100000..999999).to_s
    
    update_columns(
      otp_secret: otp,
      otp_sent_at: Time.current
    )
  end

  def verify_otp(code)
    return false if otp_secret.blank? || otp_sent_at.blank?
    return false if otp_expired?
    
    otp_secret == code.to_s
  end

  def otp_expired?
    return true if otp_sent_at.blank?
    
    otp_sent_at < Time.current - OTP_EXPIRY_TIME
  end

  def clear_otp
    update_columns(
      otp_secret: nil,
      otp_sent_at: nil
    )
  end

  def otp_required?
    otp_required_for_login?
  end
end




