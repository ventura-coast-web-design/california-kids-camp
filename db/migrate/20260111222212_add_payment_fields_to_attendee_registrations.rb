class AddPaymentFieldsToAttendeeRegistrations < ActiveRecord::Migration[8.1]
  def change
    add_column :attendee_registrations, :stripe_payment_intent_id, :string
    add_column :attendee_registrations, :amount_paid, :decimal, precision: 10, scale: 2
    add_column :attendee_registrations, :payment_status, :string, default: 'pending'
  end
end
