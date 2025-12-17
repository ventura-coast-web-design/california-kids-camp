class CreateAttendees < ActiveRecord::Migration[8.1]
  def change
    create_table :attendees do |t|
      # Add your attendee fields here
      # Example: t.string :name
      # Example: t.integer :age
      # Example: t.string :ecclesia

      t.timestamps
    end
  end
end
