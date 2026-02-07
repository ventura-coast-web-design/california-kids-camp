class AttendeeRegistration < ApplicationRecord
  # Associations
  has_many :attendees, dependent: :destroy
  accepts_nested_attributes_for :attendees, allow_destroy: true, reject_if: :all_blank

  # Validations
  validates :guardian_1_name, :guardian_1_email, :guardian_1_phone, presence: true
  validates :guardian_1_address_line_1, :guardian_1_city, :guardian_1_state, :guardian_1_zip, presence: true
  validates :guardian_1_email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :guardian_1_phone, format: { with: /\A[\d\s\-\(\)\+\.]+\z/, message: "must be a valid phone number" }
  validates :guardian_1_state, length: { is: 2, message: "must be 2 characters (e.g., CA)" }
  validates :guardian_1_zip, format: { with: /\A\d{5}(-\d{4})?\z/, message: "must be a valid ZIP code" }

  # Guardian 2 validations (if provided)
  validates :guardian_2_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :guardian_2_phone, format: { with: /\A[\d\s\-\(\)\+\.]+\z/, message: "must be a valid phone number" }, allow_blank: true
  validates :guardian_2_state, length: { is: 2, message: "must be 2 characters" }, allow_blank: true, if: -> { guardian_2_address_line_1.present? }
  validates :guardian_2_zip, format: { with: /\A\d{5}(-\d{4})?\z/, message: "must be a valid ZIP code" }, allow_blank: true, if: -> { guardian_2_address_line_1.present? }

  validates :emergency_contact_1_name, :emergency_contact_1_phone, presence: true
  validates :emergency_contact_1_phone, format: { with: /\A[\d\s\-\(\)\+\.]+\z/, message: "must be a valid phone number" }
  validates :emergency_contact_2_phone, format: { with: /\A[\d\s\-\(\)\+\.]+\z/, message: "must be a valid phone number" }, allow_blank: true

  validates :terms_agreement, acceptance: true
  validates :medical_consent, acceptance: true

  # Validate at least one attendee
  validate :must_have_at_least_one_attendee

  # Set pricing type before validation on create
  before_validation :set_pricing_type, on: :create

  # Early bird pricing ends March 31st
  EARLY_BIRD_END_DATE = Date.new(2026, 3, 31)

  # Payment calculation based on number of children and pricing type
  # Regular pricing: 1 child: $275, 2 children: $550, 3+ children: $650 (family max)
  # Early bird pricing: 1 child: $225, 2 children: $450, 3+ children: $500 (family max)
  def calculate_total_amount
    child_count = attendees.reject(&:marked_for_destruction?).count
    is_early_bird = pricing_type == "early_bird"

    case child_count
    when 1
      is_early_bird ? 225.00 : 275.00
    when 2
      is_early_bird ? 450.00 : 550.00
    else
      is_early_bird ? 500.00 : 650.00 # Family max for 3 or more
    end
  end

  # Calculate deposit amount: $50 per attendee
  def calculate_deposit_amount
    child_count = attendees.reject(&:marked_for_destruction?).count
    (child_count * 50.00).round(2)
  end

  # Convert amount to cents for Stripe
  def amount_in_cents
    (calculate_total_amount * 100).to_i
  end

  # Convert deposit amount to cents for Stripe
  def deposit_amount_in_cents
    (calculate_deposit_amount * 100).to_i
  end

  def paid?
    payment_status == "succeeded"
  end

  def paid_in_full?
    return false unless paid?
    return true if payment_type.to_s == "full"
    # If payment_type is not set but amount_paid equals total, assume full payment
    return true if payment_type.blank? && amount_paid.to_f >= calculate_total_amount
    # If remaining balance is zero, registration is paid in full
    return true if remaining_balance <= 0.0
    false
  end

  def paid_deposit?
    return false unless paid?
    return true if payment_type.to_s == "deposit"
    # If payment_type is not set but amount_paid is less than total, assume deposit
    return true if payment_type.blank? && amount_paid.to_f > 0 && amount_paid.to_f < calculate_total_amount
    false
  end

  def payment_status_display
    return "Not Paid" unless paid?
    return "Paid in Full" if paid_in_full?
    return "Deposit Paid" if paid_deposit?
    "Paid"
  end

  def remaining_balance
    return 0.0 unless paid?

    total = calculate_total_amount.to_f
    paid = amount_paid.to_f

    # Handle nil amount_paid
    paid = 0.0 if paid.nil? || paid.nan?

    balance = total - paid

    # Round to 2 decimal places to avoid floating point precision issues
    balance = balance.round(2)

    # Return 0 if balance is very close to zero (within 1 cent) due to floating point precision
    balance.abs < 0.01 ? 0.0 : balance
  end

  # Calculate per-attendee total amount
  # This divides the total registration cost evenly among all attendees
  def calculate_per_attendee_total
    child_count = attendees.reject(&:marked_for_destruction?).count
    return 0.0 if child_count.zero?
    (calculate_total_amount / child_count.to_f).round(2)
  end

  # Calculate per-attendee amount paid
  # This divides the total amount paid evenly among all attendees
  def calculate_per_attendee_paid
    child_count = attendees.reject(&:marked_for_destruction?).count
    return 0.0 if child_count.zero? || amount_paid.to_f.zero?
    (amount_paid.to_f / child_count.to_f).round(2)
  end

  # Calculate per-attendee remaining balance
  def calculate_per_attendee_balance
    calculate_per_attendee_total - calculate_per_attendee_paid
  end

  def early_bird_eligible?
    Date.current < EARLY_BIRD_END_DATE
  end

  def pricing_type_display
    case pricing_type
    when "early_bird"
      "Early Bird"
    else
      "Regular"
    end
  end

  private

  def set_pricing_type
    # Always set pricing type on create based on eligibility, regardless of default value
    self.pricing_type = early_bird_eligible? ? "early_bird" : "regular"
  end

  def must_have_at_least_one_attendee
    if attendees.empty? || attendees.all?(&:marked_for_destruction?)
      errors.add(:base, "Must register at least one attendee")
    end
  end
end
