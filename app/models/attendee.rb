class Attendee < ApplicationRecord
  # Associations
  belongs_to :attendee_registration

  # Validations
  validates :first_name, :last_name, :date_of_birth, presence: true
  validates :age, numericality: { greater_than: 0, less_than: 100 }, allow_nil: true
  validate :date_of_birth_must_be_in_past
  validates :phone, presence: true, format: { with: /\A[\d\s\-\(\)\+\.]+\z/, message: "must be a valid phone number" }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :ecclesia, presence: true
  validates :medical_conditions, :dietary_restrictions, :allergies, presence: true
  # If attendee provides their own address (address_line_1 present), validate all address fields
  validates :city, presence: true, if: -> { address_line_1.present? }
  validates :state, presence: true, length: { is: 2, message: "must be 2 characters" }, if: -> { address_line_1.present? }
  validates :zip, presence: true, format: { with: /\A\d{5}(-\d{4})?\z/, message: "must be a valid ZIP code" }, if: -> { address_line_1.present? }

  # Calculate age from date of birth before validation
  before_validation :calculate_age_from_dob
  # Copy guardian 1 address if attendee address is blank (checkbox was checked)
  before_validation :copy_guardian_1_address_if_blank

  private

  def copy_guardian_1_address_if_blank
    # If address_line_1 is blank, copy from guardian 1
    return unless address_line_1.blank? && attendee_registration.present?

    registration = attendee_registration
    self.address_line_1 = registration.guardian_1_address_line_1
    self.address_line_2 = registration.guardian_1_address_line_2
    self.city = registration.guardian_1_city
    self.state = registration.guardian_1_state
    self.zip = registration.guardian_1_zip
  end

  def date_of_birth_must_be_in_past
    return unless date_of_birth.present?

    if date_of_birth >= Date.today
      errors.add(:date_of_birth, "must be in the past")
    end
  end

  def calculate_age_from_dob
    return unless date_of_birth.present?

    now = Time.current.to_date
    self.age = now.year - date_of_birth.year
    self.age -= 1 if now < date_of_birth + age.years
  end
end
