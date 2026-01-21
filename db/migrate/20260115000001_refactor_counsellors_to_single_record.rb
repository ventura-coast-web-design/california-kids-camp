class RefactorCounsellorsToSingleRecord < ActiveRecord::Migration[8.1]
  def up
    # Remove old counselor_1 and counselor_2 fields
    remove_column :counsellors, :counsellor_1_first_name, :string
    remove_column :counsellors, :counsellor_1_last_name, :string
    remove_column :counsellors, :counsellor_1_address_line_1, :string
    remove_column :counsellors, :counsellor_1_city, :string
    remove_column :counsellors, :counsellor_1_state_province_region, :string
    remove_column :counsellors, :counsellor_1_postal_code, :string
    remove_column :counsellors, :counsellor_1_country, :string
    remove_column :counsellors, :counsellor_1_phone, :string
    remove_column :counsellors, :counsellor_1_email, :string
    remove_column :counsellors, :counsellor_1_ecclesia, :string
    remove_column :counsellors, :counsellor_1_tshirt_size, :string
    remove_column :counsellors, :counsellor_1_piano, :string
    
    remove_column :counsellors, :counsellor_2_first_name, :string
    remove_column :counsellors, :counsellor_2_last_name, :string
    remove_column :counsellors, :counsellor_2_address_line_1, :string
    remove_column :counsellors, :counsellor_2_city, :string
    remove_column :counsellors, :counsellor_2_state_province_region, :string
    remove_column :counsellors, :counsellor_2_postal_code, :string
    remove_column :counsellors, :counsellor_2_country, :string
    remove_column :counsellors, :counsellor_2_phone, :string
    remove_column :counsellors, :counsellor_2_email, :string
    remove_column :counsellors, :counsellor_2_ecclesia, :string
    remove_column :counsellors, :counsellor_2_tshirt_size, :string
    remove_column :counsellors, :counsellor_2_piano, :string

    # Add single counselor fields
    add_column :counsellors, :first_name, :string, null: false
    add_column :counsellors, :last_name, :string, null: false
    add_column :counsellors, :gender, :string, null: false
    add_column :counsellors, :address_line_1, :string, null: false
    add_column :counsellors, :city, :string, null: false
    add_column :counsellors, :state_province_region, :string, null: false
    add_column :counsellors, :postal_code, :string, null: false
    add_column :counsellors, :country, :string, null: false, default: 'United States of America'
    add_column :counsellors, :phone, :string, null: false
    add_column :counsellors, :email, :string, null: false
    add_column :counsellors, :ecclesia, :string, null: false
    add_column :counsellors, :tshirt_size, :string, null: false
    add_column :counsellors, :piano, :string, null: false
    
    # Add pairing and squirts fields
    add_column :counsellors, :pairing_group_id, :string
    add_column :counsellors, :pairing_index, :integer
    add_column :counsellors, :squirts, :text
  end

  def down
    # Reverse the changes
    remove_column :counsellors, :first_name, :string
    remove_column :counsellors, :last_name, :string
    remove_column :counsellors, :gender, :string
    remove_column :counsellors, :address_line_1, :string
    remove_column :counsellors, :city, :string
    remove_column :counsellors, :state_province_region, :string
    remove_column :counsellors, :postal_code, :string
    remove_column :counsellors, :country, :string
    remove_column :counsellors, :phone, :string
    remove_column :counsellors, :email, :string
    remove_column :counsellors, :ecclesia, :string
    remove_column :counsellors, :tshirt_size, :string
    remove_column :counsellors, :piano, :string
    remove_column :counsellors, :pairing_group_id, :string
    remove_column :counsellors, :pairing_index, :integer
    remove_column :counsellors, :squirts, :text

    # Restore old fields (would need to be populated from existing data)
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
