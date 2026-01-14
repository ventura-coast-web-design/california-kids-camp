class AddPaymentTypeToAttendeeRegistrations < ActiveRecord::Migration[8.1]
  def change
    add_column :attendee_registrations, :payment_type, :string
  end
end
