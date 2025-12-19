class CreateAttendeeRegistrations < ActiveRecord::Migration[8.1]
  def change
    create_table :attendee_registrations do |t|
      # Terms and Agreement
      t.boolean :terms_agreement, default: false, null: false
      # Primary Guardian Information
      t.string :guardian_1_name, null: false
      t.string :guardian_1_email, null: false
      t.string :guardian_1_phone, null: false
      t.string :guardian_1_address_line_1, null: false
      t.string :guardian_1_address_line_2
      t.string :guardian_1_city, null: false
      t.string :guardian_1_state, null: false
      t.string :guardian_1_zip, null: false
      # Secondary Guardian Information (Optional)
      t.string :guardian_2_name
      t.string :guardian_2_email
      t.string :guardian_2_phone
      t.boolean :guardian_2_same_address, default: true
      t.string :guardian_2_address_line_1
      t.string :guardian_2_address_line_2
      t.string :guardian_2_city
      t.string :guardian_2_state
      t.string :guardian_2_zip
      # Interest in Counselling
      t.boolean :interest_in_counselling, default: false
      # General Notes
      t.text :notes
      t.timestamps
    end
  end
end
