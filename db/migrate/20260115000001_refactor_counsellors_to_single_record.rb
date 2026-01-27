class RefactorCounsellorsToSingleRecord < ActiveRecord::Migration[8.1]
  def up
    # Check if old columns exist before trying to migrate data
    old_columns_exist = column_exists?(:counsellors, :counsellor_1_first_name)
    
    # Add single counselor fields as nullable first
    add_column :counsellors, :first_name, :string unless column_exists?(:counsellors, :first_name)
    add_column :counsellors, :last_name, :string unless column_exists?(:counsellors, :last_name)
    add_column :counsellors, :gender, :string unless column_exists?(:counsellors, :gender)
    add_column :counsellors, :address_line_1, :string unless column_exists?(:counsellors, :address_line_1)
    add_column :counsellors, :city, :string unless column_exists?(:counsellors, :city)
    add_column :counsellors, :state_province_region, :string unless column_exists?(:counsellors, :state_province_region)
    add_column :counsellors, :postal_code, :string unless column_exists?(:counsellors, :postal_code)
    add_column :counsellors, :country, :string, default: 'United States of America' unless column_exists?(:counsellors, :country)
    add_column :counsellors, :phone, :string unless column_exists?(:counsellors, :phone)
    add_column :counsellors, :email, :string unless column_exists?(:counsellors, :email)
    add_column :counsellors, :ecclesia, :string unless column_exists?(:counsellors, :ecclesia)
    add_column :counsellors, :tshirt_size, :string unless column_exists?(:counsellors, :tshirt_size)
    add_column :counsellors, :piano, :string unless column_exists?(:counsellors, :piano)
    
    # Add pairing and squirts fields
    add_column :counsellors, :pairing_group_id, :string unless column_exists?(:counsellors, :pairing_group_id)
    add_column :counsellors, :pairing_index, :integer unless column_exists?(:counsellors, :pairing_index)
    add_column :counsellors, :squirts, :text unless column_exists?(:counsellors, :squirts)

    # Migrate data from old columns to new columns if old columns exist
    if old_columns_exist
      execute <<-SQL
        UPDATE counsellors
        SET 
          first_name = COALESCE(counsellor_1_first_name, ''),
          last_name = COALESCE(counsellor_1_last_name, ''),
          address_line_1 = COALESCE(counsellor_1_address_line_1, ''),
          city = COALESCE(counsellor_1_city, ''),
          state_province_region = COALESCE(counsellor_1_state_province_region, ''),
          postal_code = COALESCE(counsellor_1_postal_code, ''),
          country = COALESCE(counsellor_1_country, 'United States of America'),
          phone = COALESCE(counsellor_1_phone, ''),
          email = COALESCE(counsellor_1_email, ''),
          ecclesia = COALESCE(counsellor_1_ecclesia, ''),
          tshirt_size = COALESCE(counsellor_1_tshirt_size, ''),
          piano = COALESCE(counsellor_1_piano, '')
        WHERE first_name IS NULL OR first_name = '';
      SQL
    end

    # Remove old counselor_1 and counselor_2 fields if they exist
    remove_column :counsellors, :counsellor_1_first_name, :string if column_exists?(:counsellors, :counsellor_1_first_name)
    remove_column :counsellors, :counsellor_1_last_name, :string if column_exists?(:counsellors, :counsellor_1_last_name)
    remove_column :counsellors, :counsellor_1_address_line_1, :string if column_exists?(:counsellors, :counsellor_1_address_line_1)
    remove_column :counsellors, :counsellor_1_city, :string if column_exists?(:counsellors, :counsellor_1_city)
    remove_column :counsellors, :counsellor_1_state_province_region, :string if column_exists?(:counsellors, :counsellor_1_state_province_region)
    remove_column :counsellors, :counsellor_1_postal_code, :string if column_exists?(:counsellors, :counsellor_1_postal_code)
    remove_column :counsellors, :counsellor_1_country, :string if column_exists?(:counsellors, :counsellor_1_country)
    remove_column :counsellors, :counsellor_1_phone, :string if column_exists?(:counsellors, :counsellor_1_phone)
    remove_column :counsellors, :counsellor_1_email, :string if column_exists?(:counsellors, :counsellor_1_email)
    remove_column :counsellors, :counsellor_1_ecclesia, :string if column_exists?(:counsellors, :counsellor_1_ecclesia)
    remove_column :counsellors, :counsellor_1_tshirt_size, :string if column_exists?(:counsellors, :counsellor_1_tshirt_size)
    remove_column :counsellors, :counsellor_1_piano, :string if column_exists?(:counsellors, :counsellor_1_piano)
    
    remove_column :counsellors, :counsellor_2_first_name, :string if column_exists?(:counsellors, :counsellor_2_first_name)
    remove_column :counsellors, :counsellor_2_last_name, :string if column_exists?(:counsellors, :counsellor_2_last_name)
    remove_column :counsellors, :counsellor_2_address_line_1, :string if column_exists?(:counsellors, :counsellor_2_address_line_1)
    remove_column :counsellors, :counsellor_2_city, :string if column_exists?(:counsellors, :counsellor_2_city)
    remove_column :counsellors, :counsellor_2_state_province_region, :string if column_exists?(:counsellors, :counsellor_2_state_province_region)
    remove_column :counsellors, :counsellor_2_postal_code, :string if column_exists?(:counsellors, :counsellor_2_postal_code)
    remove_column :counsellors, :counsellor_2_country, :string if column_exists?(:counsellors, :counsellor_2_country)
    remove_column :counsellors, :counsellor_2_phone, :string if column_exists?(:counsellors, :counsellor_2_phone)
    remove_column :counsellors, :counsellor_2_email, :string if column_exists?(:counsellors, :counsellor_2_email)
    remove_column :counsellors, :counsellor_2_ecclesia, :string if column_exists?(:counsellors, :counsellor_2_ecclesia)
    remove_column :counsellors, :counsellor_2_tshirt_size, :string if column_exists?(:counsellors, :counsellor_2_tshirt_size)
    remove_column :counsellors, :counsellor_2_piano, :string if column_exists?(:counsellors, :counsellor_2_piano)
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
