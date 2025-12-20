class AddEmergencyFieldsToAttendeeRegistrations < ActiveRecord::Migration[8.1]
  def change
    add_column :attendee_registrations, :medical_consent, :boolean, default: false, null: false
    add_column :attendee_registrations, :emergency_contact_1_name, :string, null: false
    add_column :attendee_registrations, :emergency_contact_1_phone, :string, null: false
    add_column :attendee_registrations, :emergency_contact_2_name, :string
    add_column :attendee_registrations, :emergency_contact_2_phone, :string
  end
end
