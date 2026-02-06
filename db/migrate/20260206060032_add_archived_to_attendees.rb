class AddArchivedToAttendees < ActiveRecord::Migration[8.1]
  def change
    add_column :attendees, :archived, :boolean, default: false, null: false
  end
end
