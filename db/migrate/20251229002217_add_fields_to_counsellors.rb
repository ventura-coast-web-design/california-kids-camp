class AddFieldsToCounsellors < ActiveRecord::Migration[8.1]
  def change
    # Counselor 1 fields
    add_column :counsellors, :counsellor_1_first_name, :string, null: false
    add_column :counsellors, :counsellor_1_last_name, :string, null: false
    add_column :counsellors, :counsellor_1_address_line_1, :string, null: false
    add_column :counsellors, :counsellor_1_city, :string, null: false
    add_column :counsellors, :counsellor_1_state_province_region, :string, null: false
    add_column :counsellors, :counsellor_1_postal_code, :string, null: false
    add_column :counsellors, :counsellor_1_country, :string, null: false, default: 'United States of America'
    add_column :counsellors, :counsellor_1_phone, :string, null: false
    add_column :counsellors, :counsellor_1_email, :string, null: false
    add_column :counsellors, :counsellor_1_ecclesia, :string, null: false
    add_column :counsellors, :counsellor_1_tshirt_size, :string, null: false
    add_column :counsellors, :counsellor_1_piano, :string, null: false

    # Counselor 2 fields
    add_column :counsellors, :counsellor_2_first_name, :string, null: false
    add_column :counsellors, :counsellor_2_last_name, :string, null: false
    add_column :counsellors, :counsellor_2_address_line_1, :string, null: false
    add_column :counsellors, :counsellor_2_city, :string, null: false
    add_column :counsellors, :counsellor_2_state_province_region, :string, null: false
    add_column :counsellors, :counsellor_2_postal_code, :string, null: false
    add_column :counsellors, :counsellor_2_country, :string, null: false, default: 'United States of America'
    add_column :counsellors, :counsellor_2_phone, :string, null: false
    add_column :counsellors, :counsellor_2_email, :string, null: false
    add_column :counsellors, :counsellor_2_ecclesia, :string, null: false
    add_column :counsellors, :counsellor_2_tshirt_size, :string, null: false
    add_column :counsellors, :counsellor_2_piano, :string, null: false
  end
end
