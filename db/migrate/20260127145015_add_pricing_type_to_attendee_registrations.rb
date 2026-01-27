class AddPricingTypeToAttendeeRegistrations < ActiveRecord::Migration[8.1]
  def change
    add_column :attendee_registrations, :pricing_type, :string, default: 'regular'
  end
end
