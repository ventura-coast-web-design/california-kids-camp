# Registration System Setup

This document explains the three-tier registration system that has been set up for California Kids Camp.

## Overview

The application now supports three types of registration:

1. **Admin Registration** - Full authentication with login (Devise)
2. **Attendee Registration** - Data collection only (no login)
3. **Counsellor Registration** - Data collection only (no login)

## Structure

### 1. Admin Registration (Devise - Existing)
- **Model**: `User` (app/models/user.rb)
- **Migration**: `db/migrate/20241216000001_devise_create_users.rb`
- **Controller**: `Users::RegistrationsController` (app/controllers/users/registrations_controller.rb)
- **View**: `app/views/devise/registrations/new.html.erb`
- **Routes**: 
  - GET `/users/sign_up` - Registration form
  - POST `/users` - Create admin account
  - GET `/users/sign_in` - Login
- **Features**: Full Devise authentication, 2FA/OTP support

### 2. Attendee Registration (New - Data Collection)
- **Model**: `Attendee` (app/models/attendee.rb)
- **Migration**: `db/migrate/20251217061723_create_attendees.rb` ⚠️ **NEEDS FIELDS**
- **Controller**: `AttendeesController` (app/controllers/attendees_controller.rb)
- **View**: `app/views/attendees/new.html.erb`
- **Routes**: 
  - GET `/attendees/register` - Registration form
  - POST `/attendees` - Submit registration
- **Features**: Public access, no authentication required

### 3. Counsellor Registration (New - Data Collection)
- **Model**: `Counsellor` (app/models/counsellor.rb)
- **Migration**: `db/migrate/20251217061731_create_counsellors.rb` ⚠️ **NEEDS FIELDS**
- **Controller**: `CounsellorsController` (app/controllers/counsellors_controller.rb)
- **View**: `app/views/counsellors/new.html.erb`
- **Routes**: 
  - GET `/counsellors/register` - Registration form
  - POST `/counsellors` - Submit registration
- **Features**: Public access, no authentication required

## Next Steps - Before Running Migrations

### 1. Add Fields to Attendee Migration
Edit `db/migrate/20251217061723_create_attendees.rb`:

```ruby
class CreateAttendees < ActiveRecord::Migration[8.1]
  def change
    create_table :attendees do |t|
      # Example fields (customize as needed):
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.date :date_of_birth
      t.integer :age
      t.string :gender
      t.string :ecclesia
      
      # Parent/Guardian Information
      t.string :parent_name, null: false
      t.string :parent_email, null: false
      t.string :parent_phone, null: false
      t.string :emergency_contact
      t.string :emergency_phone
      
      # Medical/Dietary
      t.text :medical_conditions
      t.text :dietary_restrictions
      t.text :allergies
      
      # Other
      t.text :special_needs
      t.text :notes
      
      t.timestamps
    end
  end
end
```

### 2. Add Fields to Counsellor Migration
Edit `db/migrate/20251217061731_create_counsellors.rb`:

```ruby
class CreateCounsellors < ActiveRecord::Migration[8.1]
  def change
    create_table :counsellors do |t|
      # Example fields (customize as needed):
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :phone, null: false
      t.date :date_of_birth
      t.string :ecclesia
      
      # Experience
      t.text :previous_experience
      t.text :skills
      t.boolean :first_aid_certified, default: false
      t.text :availability
      
      # References
      t.string :reference_1_name
      t.string :reference_1_phone
      t.string :reference_1_email
      t.string :reference_2_name
      t.string :reference_2_phone
      t.string :reference_2_email
      
      # Background Check
      t.boolean :background_check_completed, default: false
      t.date :background_check_date
      
      # Other
      t.text :notes
      
      t.timestamps
    end
  end
end
```

### 3. Update Controller Permitted Parameters

**AttendeesController** (app/controllers/attendees_controller.rb):
Update the `attendee_params` method to permit your fields:

```ruby
def attendee_params
  params.require(:attendee).permit(
    :first_name, :last_name, :date_of_birth, :age, :gender, :ecclesia,
    :parent_name, :parent_email, :parent_phone, :emergency_contact, :emergency_phone,
    :medical_conditions, :dietary_restrictions, :allergies, :special_needs, :notes
  )
end
```

**CounsellorsController** (app/controllers/counsellors_controller.rb):
Update the `counsellor_params` method to permit your fields:

```ruby
def counsellor_params
  params.require(:counsellor).permit(
    :first_name, :last_name, :email, :phone, :date_of_birth, :ecclesia,
    :previous_experience, :skills, :first_aid_certified, :availability,
    :reference_1_name, :reference_1_phone, :reference_1_email,
    :reference_2_name, :reference_2_phone, :reference_2_email,
    :background_check_completed, :background_check_date, :notes
  )
end
```

### 4. Add Form Fields to Views

**Attendees** (app/views/attendees/new.html.erb):
Uncomment and customize the example form fields based on your migration fields.

**Counsellors** (app/views/counsellors/new.html.erb):
Uncomment and customize the example form fields based on your migration fields.

### 5. Add Validations to Models (Optional but Recommended)

**Attendee** (app/models/attendee.rb):
```ruby
class Attendee < ApplicationRecord
  validates :first_name, :last_name, :parent_name, :parent_email, :parent_phone, presence: true
  validates :parent_email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :age, numericality: { greater_than: 0, less_than: 100 }, allow_nil: true
end
```

**Counsellor** (app/models/counsellor.rb):
```ruby
class Counsellor < ApplicationRecord
  validates :first_name, :last_name, :email, :phone, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
end
```

## Running the Migrations

After adding your fields:

```bash
rails db:migrate
```

## Testing the Registration Forms

- **Admin Registration**: http://localhost:3000/users/sign_up
- **Attendee Registration**: http://localhost:3000/attendees/register
- **Counsellor Registration**: http://localhost:3000/counsellors/register

## Security Notes

- Attendee and Counsellor controllers skip authentication by design
- All data is stored in the database for admin review
- Consider adding email confirmation for attendee/counsellor submissions
- Consider adding CAPTCHA to prevent spam submissions

## Future Enhancements

- Add admin dashboard to view and manage registrations
- Add email notifications when new registrations are submitted
- Add ability to export registration data
- Add registration status tracking (pending, approved, rejected)
- Add payment integration for camp fees
