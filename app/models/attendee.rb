class Attendee < ApplicationRecord
  # Associations
  belongs_to :attendee_registration

  # Validations
  validates :first_name, :last_name, :date_of_birth, presence: true
  validates :age, numericality: { greater_than: 0, less_than: 100 }, allow_nil: true

  # Calculate age from date of birth before validation
  before_validation :calculate_age_from_dob

  private

  def calculate_age_from_dob
    return unless date_of_birth.present?

    now = Time.current.to_date
    self.age = now.year - date_of_birth.year
    self.age -= 1 if now < date_of_birth + age.years
  end
end
