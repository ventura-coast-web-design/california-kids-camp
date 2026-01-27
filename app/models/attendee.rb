class Attendee < ApplicationRecord
  # Associations
  belongs_to :attendee_registration

  # Validations
  validates :first_name, :last_name, :date_of_birth, presence: true
  validates :age, numericality: { greater_than_or_equal_to: 9, less_than_or_equal_to: 17 }, allow_nil: true
  validate :date_of_birth_must_be_in_past
  validate :age_must_be_between_9_and_17
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

  # Camp date: June 21, 2026
  CAMP_START_DATE = Date.new(2026, 6, 21)

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

  def age_must_be_between_9_and_17
    return unless date_of_birth.present?

    camp_age = calculate_age_on_date(CAMP_START_DATE)
    return unless camp_age.present?

    if camp_age < 9
      errors.add(:date_of_birth, "attendee must be at least 9 years old on June 21, 2026")
    elsif camp_age > 17
      errors.add(:date_of_birth, "attendee must be 17 years old or younger on June 21, 2026")
    end
  end

  def calculate_age_from_dob
    return unless date_of_birth.present?

    now = Time.current.to_date
    self.age = now.year - date_of_birth.year
    self.age -= 1 if now < date_of_birth + age.years
  end

  def calculate_age_on_date(target_date)
    return nil unless date_of_birth.present?

    age = target_date.year - date_of_birth.year
    age -= 1 if target_date < date_of_birth + age.years
    age
  end
end
