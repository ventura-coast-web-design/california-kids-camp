# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_12_29_002217) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "attendee_registrations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "emergency_contact_1_name", null: false
    t.string "emergency_contact_1_phone", null: false
    t.string "emergency_contact_2_name"
    t.string "emergency_contact_2_phone"
    t.string "guardian_1_address_line_1", null: false
    t.string "guardian_1_address_line_2"
    t.string "guardian_1_city", null: false
    t.string "guardian_1_email", null: false
    t.string "guardian_1_name", null: false
    t.string "guardian_1_phone", null: false
    t.string "guardian_1_state", null: false
    t.string "guardian_1_zip", null: false
    t.string "guardian_2_address_line_1"
    t.string "guardian_2_address_line_2"
    t.string "guardian_2_city"
    t.string "guardian_2_email"
    t.string "guardian_2_name"
    t.string "guardian_2_phone"
    t.boolean "guardian_2_same_address", default: true
    t.string "guardian_2_state"
    t.string "guardian_2_zip"
    t.boolean "interest_in_counselling", default: false
    t.boolean "medical_consent", default: false, null: false
    t.text "notes"
    t.boolean "terms_agreement", default: false, null: false
    t.datetime "updated_at", null: false
  end

  create_table "attendees", force: :cascade do |t|
    t.string "address_line_1"
    t.string "address_line_2"
    t.integer "age"
    t.text "allergies"
    t.bigint "attendee_registration_id", null: false
    t.string "city"
    t.datetime "created_at", null: false
    t.date "date_of_birth", null: false
    t.text "dietary_restrictions"
    t.string "ecclesia"
    t.string "email"
    t.string "first_name", null: false
    t.string "gender"
    t.string "last_name", null: false
    t.text "medical_conditions"
    t.text "notes"
    t.string "phone"
    t.boolean "piano"
    t.text "special_needs"
    t.string "state"
    t.string "tshirt_size"
    t.datetime "updated_at", null: false
    t.string "zip"
    t.index ["attendee_registration_id"], name: "index_attendees_on_attendee_registration_id"
  end

  create_table "counsellors", force: :cascade do |t|
    t.string "counsellor_1_address_line_1", null: false
    t.string "counsellor_1_city", null: false
    t.string "counsellor_1_country", default: "United States of America", null: false
    t.string "counsellor_1_ecclesia", null: false
    t.string "counsellor_1_email", null: false
    t.string "counsellor_1_first_name", null: false
    t.string "counsellor_1_last_name", null: false
    t.string "counsellor_1_phone", null: false
    t.string "counsellor_1_piano", null: false
    t.string "counsellor_1_postal_code", null: false
    t.string "counsellor_1_state_province_region", null: false
    t.string "counsellor_1_tshirt_size", null: false
    t.string "counsellor_2_address_line_1", null: false
    t.string "counsellor_2_city", null: false
    t.string "counsellor_2_country", default: "United States of America", null: false
    t.string "counsellor_2_ecclesia", null: false
    t.string "counsellor_2_email", null: false
    t.string "counsellor_2_first_name", null: false
    t.string "counsellor_2_last_name", null: false
    t.string "counsellor_2_phone", null: false
    t.string "counsellor_2_piano", null: false
    t.string "counsellor_2_postal_code", null: false
    t.string "counsellor_2_state_province_region", null: false
    t.string "counsellor_2_tshirt_size", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ecclesia"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", null: false
    t.boolean "otp_required_for_login", default: false
    t.string "otp_secret"
    t.datetime "otp_sent_at"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "attendees", "attendee_registrations"
end
