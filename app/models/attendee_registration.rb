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

  # Payment calculation based on number of children
  # 1 child: $275, 2 children: $550, 3+ children: $650 (family max)
  def calculate_total_amount
    child_count = attendees.reject(&:marked_for_destruction?).count
    
    case child_count
    when 1
      275.00
    when 2
      550.00
    else
      650.00 # Family max for 3 or more
    end
  end

  # Convert amount to cents for Stripe
  def amount_in_cents
    (calculate_total_amount * 100).to_i
  end

  def paid?
    payment_status == 'succeeded'
  end

  private

  def must_have_at_least_one_attendee
    if attendees.empty? || attendees.all?(&:marked_for_destruction?)
      errors.add(:base, "Must register at least one attendee")
    end
  end
end
