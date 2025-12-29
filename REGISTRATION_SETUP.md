# Registration System Setup

This document explains the three-tier registration system that has been set up for California Kids Camp.

## Overview

The application now supports three types of registration:

1. **Admin Registration** - Full authentication with login (Devise)
2. **Attendee Registration** - Data collection only (no login) - Supports multiple children per registration
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

### 2. Attendee Registration (New - Data Collection with Multiple Children)
This uses a parent-child relationship to allow guardians to register multiple children in one form submission.

#### Parent Model - AttendeeRegistration
- **Model**: `AttendeeRegistration` (app/models/attendee_registration.rb)
- **Migration**: `db/migrate/20251219050303_create_attendee_registrations.rb` ✅ **COMPLETE**
- **Purpose**: Stores guardian/family information (name, email, address, etc.)
- **Relationship**: `has_many :attendees`

#### Child Model - Attendee
- **Model**: `Attendee` (app/models/attendee.rb)
- **Migration**: `db/migrate/20251217061723_create_attendees.rb` ✅ **COMPLETE**
- **Purpose**: Stores individual child information (name, DOB, medical info, etc.)
- **Relationship**: `belongs_to :attendee_registration`

#### Controller & Views
- **Controller**: `AttendeeRegistrationsController` (app/controllers/attendee_registrations_controller.rb)
- **Views**: 
  - `app/views/attendee_registrations/new.html.erb` - Main registration form
  - `app/views/attendee_registrations/_attendee_fields.html.erb` - Partial for child fields
- **Routes**: 
  - GET `/attendees/register` - Registration form
  - POST `/attendee_registrations` - Submit registration
- **Features**: 
  - Public access, no authentication required
  - Dynamic JavaScript form - add/remove children as needed
  - Nested attributes for multiple children
  - Guardian 1 & Guardian 2 (optional) support
  - Automatic age calculation from date of birth

### 3. Counsellor Registration (New - Data Collection)
- **Model**: `Counsellor` (app/models/counsellor.rb)
- **Migration**: `db/migrate/20251217061731_create_counsellors.rb` ⚠️ **NEEDS FIELDS**
- **Controller**: `CounsellorsController` (app/controllers/counsellors_controller.rb)
- **View**: `app/views/counsellors/new.html.erb`
- **Routes**: 
  - GET `/counsellors/register` - Registration form
  - POST `/counsellors` - Submit registration
- **Features**: Public access, no authentication required

## Database Schema

### AttendeeRegistration Fields (Guardian/Family Info)
The migration includes:
- `terms_agreement` (boolean) - Must accept terms
- Guardian 1 fields: name, email, phone, address (required)
- Guardian 2 fields: name, email, phone, address (optional)
- `guardian_2_same_address` (boolean) - Whether Guardian 2 shares address
- `interest_in_counselling` (boolean) - If guardian wants counsellor info
- `notes` (text) - Additional notes

### Attendee Fields (Individual Child Info)
The migration includes:
- `attendee_registration_id` (reference) - Links to parent registration
- Personal: first_name, last_name, date_of_birth, age, gender, ecclesia
- Medical: medical_conditions, dietary_restrictions, allergies, special_needs
- `notes` (text) - Child-specific notes

**Note**: Age is automatically calculated from date_of_birth via a before_validation callback.

## Next Steps - Before Running Migrations

### Add Fields to Counsellor Migration
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

### Update CounsellorsController Permitted Parameters

**CounsellorsController** (app/controllers/counsellors_controller.rb):
Update the `counsellor_params` method to permit your fields (once you've added them to the migration):

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

### Add Form Fields to Counsellors View

**Counsellors** (app/views/counsellors/new.html.erb):
Uncomment and customize the example form fields based on your migration fields once you've added them.

## Model Validations

The models already include validations:

**AttendeeRegistration** (app/models/attendee_registration.rb):
- Validates presence of Guardian 1 required fields
- Validates Guardian 1 email format
- Validates terms_agreement is accepted
- Validates at least one attendee exists

**Attendee** (app/models/attendee.rb):
- Validates presence of first_name, last_name, date_of_birth
- Validates age is between 0-100
- Automatically calculates age from date_of_birth

**Counsellor** (app/models/counsellor.rb) - Add these after migration:
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

## How the Dynamic Attendee Form Works

The attendee registration form includes JavaScript functionality that allows guardians to:

1. **Start with one child form** - One child form is pre-loaded by default
2. **Add more children** - Click "+ Add Another Child" button to dynamically add more child forms
3. **Remove children** - Click "Remove" button on any child form (must keep at least one)
4. **Auto-numbering** - Child forms are automatically numbered (Child 1, Child 2, etc.)
5. **Toggle Guardian 2 address** - Checkbox to show/hide Guardian 2 address fields

The form uses:
- Rails `fields_for` with `accepts_nested_attributes_for` for server-side handling
- Vanilla JavaScript for client-side dynamic form management
- HTML5 form validation

## Testing the Registration Forms

- **Admin Registration**: http://localhost:3000/users/sign_up
- **Attendee Registration**: http://localhost:3000/attendees/register (supports multiple children!)
- **Counsellor Registration**: http://localhost:3000/counsellors/register

## Security Notes

- Attendee and Counsellor controllers skip authentication by design
- All data is stored in the database for admin review
- Consider adding email confirmation for attendee/counsellor submissions
- Consider adding CAPTCHA to prevent spam submissions

## Key Technical Details

### Nested Attributes
The `AttendeeRegistration` model uses `accepts_nested_attributes_for :attendees` which allows creating/updating multiple attendees in a single form submission.

### Age Calculation
The `Attendee` model has a `before_validation` callback that automatically calculates the age from the date of birth, so you don't need to manually enter the age.

### Data Relationships
```
AttendeeRegistration (1) ----< (many) Attendee
- Guardian info              - Child info
- Family info                - Medical info
- Terms agreement            - Belongs to registration
```

When an `AttendeeRegistration` is deleted, all associated `Attendee` records are also deleted (`dependent: :destroy`).

## Future Enhancements

- Add admin dashboard to view and manage registrations
- Add email notifications when new registrations are submitted
- Add ability to export registration data (CSV/PDF)
- Add registration status tracking (pending, approved, rejected)
- Add payment integration for camp fees
- Add emergency contact separate from guardians
- Add sibling discount calculation
- Add file upload for medical documents
- Add digital signature for terms agreement



