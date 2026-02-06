class AddArchivedToCounsellors < ActiveRecord::Migration[8.1]
  def change
    add_column :counsellors, :archived, :boolean, default: false, null: false
  end
end
