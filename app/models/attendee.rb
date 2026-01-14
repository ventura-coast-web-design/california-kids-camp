class Attendee < ApplicationRecord
  # Associations
  belongs_to :attendee_registration

  # Validations
  validates :first_name, :last_name, :date_of_birth, presence: true
  validates :age, numericality: { greater_than: 0, less_than: 100 }, allow_nil: true
  validate :date_of_birth_must_be_in_past
  validates :phone, format: { with: /\A[\d\s\-\(\)\+\.]+\z/, message: "must be a valid phone number" }, allow_blank: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :state, length: { is: 2, message: "must be 2 characters" }, allow_blank: true, if: -> { address_line_1.present? }
  validates :zip, format: { with: /\A\d{5}(-\d{4})?\z/, message: "must be a valid ZIP code" }, allow_blank: true, if: -> { address_line_1.present? }

  # Calculate age from date of birth before validation
  before_validation :calculate_age_from_dob

  private

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
