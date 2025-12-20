class CreateAttendees < ActiveRecord::Migration[8.1]
  def change
    create_table :attendees do |t|
      # Reference to the parent registration
      t.references :attendee_registration, null: false, foreign_key: true

      # Child-specific information
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.date :date_of_birth, null: false
      t.integer :age
      t.string :gender
      t.string :ecclesia

      # Medical/Dietary Information
      t.text :medical_conditions
      t.text :dietary_restrictions
      t.text :allergies
      t.text :special_needs

      # Child-specific notes
      t.text :notes

      t.timestamps
    end
  end
end
