class AddPairingRequestFieldsToCounsellors < ActiveRecord::Migration[8.1]
  def change
    add_column :counsellors, :requested_pairing_with, :text
    add_column :counsellors, :requested_pairing_name, :string
  end
end
