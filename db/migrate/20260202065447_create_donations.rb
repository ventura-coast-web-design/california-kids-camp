class CreateDonations < ActiveRecord::Migration[8.1]
  def change
    create_table :donations do |t|
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :email, null: false
      t.string :name, null: false
      t.string :stripe_payment_intent_id
      t.string :payment_status, default: "pending"

      t.timestamps
    end
    
    add_index :donations, :stripe_payment_intent_id, unique: true
    add_index :donations, :email
  end
end
