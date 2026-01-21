class Counsellor < ApplicationRecord
  # Validations
  validates :first_name, :last_name, :gender, presence: true
  validates :address_line_1, :city, :state_province_region, presence: true
  validates :postal_code, :country, presence: true
  validates :phone, :email, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, format: { with: /\A[\d\s\-\(\)\+\.]+\z/, message: "must be a valid phone number" }
  validates :postal_code, format: { with: /\A[\d\w\s\-]+\z/, message: "must be a valid postal code" }
  validates :ecclesia, :tshirt_size, :piano, presence: true
  validates :gender, inclusion: { in: %w[Male Female], message: "must be Male or Female" }

  # Parse squirts data (stored as delimited: "name|gender|age,name|gender|age")
  def squirts_array
    return [] if squirts.blank?
    squirts.split(",").map do |squirt_data|
      parts = squirt_data.split("|")
      {
        name: parts[0]&.strip,
        gender: parts[1]&.strip,
        age: parts[2]&.strip&.to_i
      }
    end
  end

  # Format squirts for display
  def squirts_display
    return "None" if squirts.blank?
    squirts_array.map { |s| "#{s[:name]} (#{s[:gender]}, Age #{s[:age]})" }.join(", ")
  end

  # Find counselors in the same pairing group
  def pairing_group
    return [] if pairing_group_id.blank?
    Counsellor.where(pairing_group_id: pairing_group_id).where.not(id: id).order(:pairing_index)
  end

  # Check if this counselor is paired with another
  def paired?
    pairing_group_id.present? && pairing_group.any?
  end
end
