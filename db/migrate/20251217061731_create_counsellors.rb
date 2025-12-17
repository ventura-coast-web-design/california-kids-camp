class CreateCounsellors < ActiveRecord::Migration[8.1]
  def change
    create_table :counsellors do |t|
      # Add your counsellor fields here
      # Example: t.string :name
      # Example: t.string :email
      # Example: t.string :ecclesia
      # Example: t.text :experience

      t.timestamps
    end
  end
end
