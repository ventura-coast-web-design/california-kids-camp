class AttendeeRegistration < ApplicationRecord
  # Associations
  has_many :attendees, dependent: :destroy
  accepts_nested_attributes_for :attendees, allow_destroy: true, reject_if: :all_blank

  # Validations
  validates :guardian_1_name, :guardian_1_email, :guardian_1_phone, presence: true
  validates :guardian_1_address_line_1, :guardian_1_city, :guardian_1_state, :guardian_1_zip, presence: true
  validates :guardian_1_email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :emergency_contact_1_name, :emergency_contact_1_phone, presence: true
  validates :terms_agreement, acceptance: true
  validates :medical_consent, acceptance: true

  # Validate at least one attendee
  validate :must_have_at_least_one_attendee

  private

  def must_have_at_least_one_attendee
    if attendees.empty? || attendees.all?(&:marked_for_destruction?)
      errors.add(:base, "Must register at least one attendee")
    end
  end
end
