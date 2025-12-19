# Attendee Registration Flow - Quick Reference

## Overview
The attendee registration system allows guardians to register **multiple children** in a single form submission using a parent-child database relationship.

## Data Structure

```
AttendeeRegistration (Parent)
├── id
├── terms_agreement
├── Guardian 1 Info (Required)
│   ├── guardian_1_name
│   ├── guardian_1_email
│   ├── guardian_1_phone
│   └── guardian_1_address (line_1, line_2, city, state, zip)
├── Guardian 2 Info (Optional)
│   ├── guardian_2_name
│   ├── guardian_2_email
│   ├── guardian_2_phone
│   ├── guardian_2_same_address (boolean)
│   └── guardian_2_address (line_1, line_2, city, state, zip)
├── interest_in_counselling
├── notes
└── has_many :attendees (Children)

Attendee (Child) - One record per child
├── id
├── attendee_registration_id (foreign key)
├── first_name
├── last_name
├── date_of_birth
├── age (auto-calculated)
├── gender
├── ecclesia
├── medical_conditions
├── dietary_restrictions
├── allergies
├── special_needs
└── notes
```

## User Flow

1. **Guardian visits** `/attendees/register`
2. **Fills out Guardian 1 info** (required)
3. **Optionally adds Guardian 2 info**
4. **Fills out first child's information** (one child form pre-loaded)
5. **Clicks "+ Add Another Child"** to add more children (as many as needed)
6. **Can remove children** by clicking "Remove" button (must keep at least 1)
7. **Accepts terms and conditions**
8. **Submits form** → Creates 1 `AttendeeRegistration` + N `Attendee` records
9. **Redirected to home** with success message

## Technical Implementation

### Models

```ruby
# app/models/attendee_registration.rb
class AttendeeRegistration < ApplicationRecord
  has_many :attendees, dependent: :destroy
  accepts_nested_attributes_for :attendees, allow_destroy: true, reject_if: :all_blank
  
  validates :guardian_1_name, :guardian_1_email, :guardian_1_phone, presence: true
  validates :terms_agreement, acceptance: true
  validate :must_have_at_least_one_attendee
end

# app/models/attendee.rb
class Attendee < ApplicationRecord
  belongs_to :attendee_registration
  
  validates :first_name, :last_name, :date_of_birth, presence: true
  before_validation :calculate_age_from_dob  # Auto-calculates age
end
```

### Controller

```ruby
# app/controllers/attendee_registrations_controller.rb
class AttendeeRegistrationsController < ApplicationController
  skip_before_action :check_otp_requirement, only: [:new, :create]
  
  def new
    @attendee_registration = AttendeeRegistration.new
    @attendee_registration.attendees.build  # Pre-load one child form
  end
  
  def create
    @attendee_registration = AttendeeRegistration.new(attendee_registration_params)
    # Saves registration + all nested attendees in one transaction
  end
end
```

### View - Dynamic Form

**Main Form**: `app/views/attendee_registrations/new.html.erb`
- Guardian information sections
- Container for attendee forms (`#attendees-container`)
- "+ Add Another Child" button
- JavaScript for dynamic form management

**Child Form Partial**: `app/views/attendee_registrations/_attendee_fields.html.erb`
- Reusable partial for each child's fields
- Used by both Rails `fields_for` and JavaScript template

### JavaScript Features

1. **Add Child**: Dynamically injects new child form with unique timestamp ID
2. **Remove Child**: Removes form from DOM (validates at least 1 remains)
3. **Auto-numbering**: Updates "Child 1", "Child 2", etc. labels
4. **Toggle Guardian 2 Address**: Shows/hides based on "same address" checkbox

## Routes

```ruby
# config/routes.rb
get "attendees/register", to: "attendee_registrations#new", as: "new_attendee"
resources :attendee_registrations, only: [:create]
```

## Database Queries

When a registration is saved:

```ruby
# This saves 1 registration + N attendees in a single transaction
registration = AttendeeRegistration.create(
  guardian_1_name: "John Doe",
  guardian_1_email: "john@example.com",
  # ... other guardian fields
  attendees_attributes: [
    { first_name: "Jane", last_name: "Doe", date_of_birth: "2010-05-15" },
    { first_name: "Jimmy", last_name: "Doe", date_of_birth: "2012-08-22" },
    { first_name: "Jenny", last_name: "Doe", date_of_birth: "2014-03-10" }
  ]
)
```

To query registrations with their children:

```ruby
# Get all registrations with their attendees
registrations = AttendeeRegistration.includes(:attendees).all

# Get a specific registration's children
registration = AttendeeRegistration.find(1)
children = registration.attendees  # => [Attendee, Attendee, ...]

# Get all children
all_children = Attendee.includes(:attendee_registration).all

# Find children by registration
kids = Attendee.where(attendee_registration_id: 1)
```

## Benefits of This Approach

✅ **No data duplication** - Guardian info stored once, not per child
✅ **Family grouping** - Easy to see all children from one family
✅ **Better UX** - Parents fill form once for multiple kids
✅ **Flexible** - Easy to add/remove children dynamically
✅ **Normalized** - Proper database design
✅ **Atomic saves** - All data saved in one transaction

## Example Admin Queries

```ruby
# How many total registrations?
AttendeeRegistration.count

# How many total children registered?
Attendee.count

# Average children per registration
Attendee.count.to_f / AttendeeRegistration.count

# Registrations with 3+ children
AttendeeRegistration.joins(:attendees)
  .group('attendee_registrations.id')
  .having('COUNT(attendees.id) >= 3')

# Find all children with dietary restrictions
Attendee.where.not(dietary_restrictions: [nil, ''])

# Get guardian email for a specific child
child = Attendee.find(1)
guardian_email = child.attendee_registration.guardian_1_email
```

## Testing Tips

When testing, create data like this:

```ruby
registration = AttendeeRegistration.create!(
  guardian_1_name: "Test Parent",
  guardian_1_email: "test@example.com",
  guardian_1_phone: "555-1234",
  guardian_1_address_line_1: "123 Main St",
  guardian_1_city: "San Francisco",
  guardian_1_state: "CA",
  guardian_1_zip: "94102",
  terms_agreement: true,
  attendees_attributes: [
    { 
      first_name: "Child", 
      last_name: "One", 
      date_of_birth: "2010-01-01",
      medical_conditions: "None"
    }
  ]
)
```
