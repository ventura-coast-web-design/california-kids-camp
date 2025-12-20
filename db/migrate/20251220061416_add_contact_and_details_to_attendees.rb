class AddContactAndDetailsToAttendees < ActiveRecord::Migration[8.1]
  def change
    add_column :attendees, :piano, :boolean, default: false
    add_column :attendees, :phone, :string
    add_column :attendees, :email, :string
    add_column :attendees, :address_line_1, :string
    add_column :attendees, :address_line_2, :string
    add_column :attendees, :city, :string
    add_column :attendees, :state, :string
    add_column :attendees, :zip, :string
    add_column :attendees, :tshirt_size, :string
  end
end
