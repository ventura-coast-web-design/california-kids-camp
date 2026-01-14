class Counsellor < ApplicationRecord
  # Counselor 1 validations
  validates :counsellor_1_first_name, :counsellor_1_last_name, presence: true
  validates :counsellor_1_address_line_1, :counsellor_1_city, :counsellor_1_state_province_region, presence: true
  validates :counsellor_1_postal_code, :counsellor_1_country, presence: true
  validates :counsellor_1_phone, :counsellor_1_email, presence: true
  validates :counsellor_1_email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :counsellor_1_phone, format: { with: /\A[\d\s\-\(\)\+\.]+\z/, message: "must be a valid phone number" }
  validates :counsellor_1_postal_code, format: { with: /\A[\d\w\s\-]+\z/, message: "must be a valid postal code" }
  validates :counsellor_1_ecclesia, :counsellor_1_tshirt_size, :counsellor_1_piano, presence: true

  # Counselor 2 validations
  validates :counsellor_2_first_name, :counsellor_2_last_name, presence: true
  validates :counsellor_2_address_line_1, :counsellor_2_city, :counsellor_2_state_province_region, presence: true
  validates :counsellor_2_postal_code, :counsellor_2_country, presence: true
  validates :counsellor_2_phone, :counsellor_2_email, presence: true
  validates :counsellor_2_email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :counsellor_2_phone, format: { with: /\A[\d\s\-\(\)\+\.]+\z/, message: "must be a valid phone number" }
  validates :counsellor_2_postal_code, format: { with: /\A[\d\w\s\-]+\z/, message: "must be a valid postal code" }
  validates :counsellor_2_ecclesia, :counsellor_2_tshirt_size, :counsellor_2_piano, presence: true
end
