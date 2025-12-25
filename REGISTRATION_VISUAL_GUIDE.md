# Registration System - Visual Guide

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                  CALIFORNIA KIDS CAMP                       │
│                   Registration System                       │
└─────────────────────────────────────────────────────────────┘
                              │
                ┌─────────────┼─────────────┐
                │             │             │
                ▼             ▼             ▼
        ┌───────────┐  ┌───────────┐  ┌───────────┐
        │   ADMIN   │  │ ATTENDEE  │  │COUNSELLOR │
        │   (User)  │  │ (Multi)   │  │ (Single)  │
        └───────────┘  └───────────┘  └───────────┘
             │              │               │
             │              │               │
        WITH LOGIN     NO LOGIN        NO LOGIN
        Full Auth      Data Only       Data Only
        2FA/OTP       Multi-Child      Single Form
```

## Attendee Registration Flow (NEW!)

```
Guardian visits: /attendees/register
            ↓
┌─────────────────────────────────────────────┐
│    STEP 1: Primary Guardian Info            │
│    ✓ Name, Email, Phone                     │
│    ✓ Full Address                           │
└─────────────────────────────────────────────┘
            ↓
┌─────────────────────────────────────────────┐
│    STEP 2: Secondary Guardian (Optional)    │
│    ○ Name, Email, Phone                     │
│    ○ Address (or same as primary)           │
└─────────────────────────────────────────────┘
            ↓
┌─────────────────────────────────────────────┐
│    STEP 3: Children Information             │
│                                             │
│    ┌─────────────────────────────┐         │
│    │  Child 1                    │         │
│    │  • Name, DOB, Gender        │         │
│    │  • Medical Info             │         │
│    │  • Dietary/Allergies        │         │
│    └─────────────────────────────┘         │
│                                             │
│    [+ Add Another Child]  <-- CLICK THIS   │
│                                             │
│    ┌─────────────────────────────┐         │
│    │  Child 2                    │         │
│    │  • Name, DOB, Gender        │         │
│    │  • Medical Info             │         │
│    │  • Dietary/Allergies        │         │
│    │  [Remove]                   │         │
│    └─────────────────────────────┘         │
│                                             │
│    ┌─────────────────────────────┐         │
│    │  Child 3                    │         │
│    │  • Name, DOB, Gender        │         │
│    │  • Medical Info             │         │
│    │  • Dietary/Allergies        │         │
│    │  [Remove]                   │         │
│    └─────────────────────────────┘         │
│                                             │
│    ... add as many as needed ...           │
└─────────────────────────────────────────────┘
            ↓
┌─────────────────────────────────────────────┐
│    STEP 4: Additional Options               │
│    □ Interest in Counselling                │
│    ☐ Notes/Questions                        │
└─────────────────────────────────────────────┘
            ↓
┌─────────────────────────────────────────────┐
│    STEP 5: Terms & Submit                   │
│    ☑ Accept Terms & Conditions              │
│    [Submit Registration]                    │
└─────────────────────────────────────────────┘
            ↓
        SAVED TO DATABASE
            ↓
    ┌───────────────────┐
    │ 1 Registration    │  AttendeeRegistration
    │   Record          │  (Guardian Info)
    └───────────────────┘
            │
            ├─────────┬─────────┬─────────
            ▼         ▼         ▼
        ┌────────┐ ┌────────┐ ┌────────┐
        │Child 1 │ │Child 2 │ │Child 3 │  Attendee
        │ Record │ │ Record │ │ Record │  (Individual Kids)
        └────────┘ └────────┘ └────────┘
```

## Database Relationships

```
┌──────────────────────────────────────┐
│     AttendeeRegistration (Parent)    │
├──────────────────────────────────────┤
│ id: 1                                │
│ guardian_1_name: "John Doe"          │
│ guardian_1_email: "john@example.com" │
│ guardian_1_phone: "555-1234"         │
│ guardian_1_address_line_1: "123..."  │
│ guardian_1_city: "San Francisco"     │
│ guardian_1_state: "CA"               │
│ guardian_1_zip: "94102"              │
│ guardian_2_name: "Jane Doe"          │
│ ... (more guardian 2 fields)         │
│ terms_agreement: true                │
│ interest_in_counselling: false       │
└──────────────────────────────────────┘
                │
                │ has_many :attendees
                │
    ┌───────────┼───────────┬───────────┐
    ▼           ▼           ▼           ▼
┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
│Attendee │ │Attendee │ │Attendee │ │   ...   │
├─────────┤ ├─────────┤ ├─────────┤ └─────────┘
│ id: 1   │ │ id: 2   │ │ id: 3   │
│ reg_id:1│ │ reg_id:1│ │ reg_id:1│
│ f_name: │ │ f_name: │ │ f_name: │
│ "Jane"  │ │ "Jimmy" │ │ "Jenny" │
│ l_name: │ │ l_name: │ │ l_name: │
│ "Doe"   │ │ "Doe"   │ │ "Doe"   │
│ dob:    │ │ dob:    │ │ dob:    │
│ 2010-.. │ │ 2012-.. │ │ 2014-.. │
│ age: 15 │ │ age: 13 │ │ age: 11 │
│ ...     │ │ ...     │ │ ...     │
└─────────┘ └─────────┘ └─────────┘
```

## Form Behavior

### Adding Children
```
Initial State:
┌─────────────┐
│  Child 1    │ (pre-loaded)
└─────────────┘

Click [+ Add Another Child]
        ↓
┌─────────────┐
│  Child 1    │
└─────────────┘
┌─────────────┐
│  Child 2    │ [Remove]  (dynamically added)
└─────────────┘

Click [+ Add Another Child] again
        ↓
┌─────────────┐
│  Child 1    │
└─────────────┘
┌─────────────┐
│  Child 2    │ [Remove]
└─────────────┘
┌─────────────┐
│  Child 3    │ [Remove]  (dynamically added)
└─────────────┘

... and so on!
```

### Removing Children
```
┌─────────────┐
│  Child 1    │
└─────────────┘
┌─────────────┐
│  Child 2    │ [Remove] ← Click this
└─────────────┘
┌─────────────┐
│  Child 3    │ [Remove]
└─────────────┘

        ↓

┌─────────────┐
│  Child 1    │ (renumbered)
└─────────────┘
┌─────────────┐
│  Child 2    │ [Remove] (was Child 3, now Child 2)
└─────────────┘
```

## JavaScript Functions

```javascript
// Main functionality in new.html.erb

1. Add Child Button Handler
   - Creates new form with unique timestamp ID
   - Inserts HTML for all child fields
   - Increments child counter
   - Updates numbering

2. Remove Child Handler (Event Delegation)
   - Validates at least 1 child remains
   - Removes form from DOM
   - Updates child numbering

3. Guardian 2 Address Toggle
   - Shows/hides address fields
   - Based on "same address" checkbox

4. Auto-numbering
   - Counts all child forms
   - Updates "Child 1", "Child 2" labels
```

## Validation Rules

```
AttendeeRegistration:
├─ Guardian 1 Name ✓ Required
├─ Guardian 1 Email ✓ Required + Valid Format
├─ Guardian 1 Phone ✓ Required
├─ Guardian 1 Address ✓ Required
├─ Guardian 2 Info ○ Optional
├─ Terms Agreement ✓ Must Accept
└─ At Least 1 Attendee ✓ Required

Attendee (Each Child):
├─ First Name ✓ Required
├─ Last Name ✓ Required
├─ Date of Birth ✓ Required
├─ Age ○ Auto-calculated
├─ Gender ○ Optional
├─ Ecclesia ○ Optional
└─ Medical Info ○ Optional
```

## Route Structure

```
GET  /attendees/register
     ↓ displays form
     AttendeeRegistrationsController#new

POST /attendee_registrations
     ↓ processes submission
     AttendeeRegistrationsController#create
     ↓ saves to database
     Redirects to root_path with success message
```

## Admin Queries (Future Dashboard)

```ruby
# Total families registered
AttendeeRegistration.count
# => 150

# Total kids registered
Attendee.count
# => 387

# Average kids per family
Attendee.count.to_f / AttendeeRegistration.count
# => 2.58

# Families with dietary restrictions
AttendeeRegistration.joins(:attendees)
  .where.not(attendees: { dietary_restrictions: [nil, ''] })
  .distinct
# => [AttendeeRegistration, ...]

# All kids from a specific registration
registration = AttendeeRegistration.find(1)
kids = registration.attendees
# => [Attendee(Jane), Attendee(Jimmy), Attendee(Jenny)]

# Contact info for a specific child
child = Attendee.find(5)
guardian_email = child.attendee_registration.guardian_1_email
# => "parent@example.com"
```

## File Structure

```
app/
├── controllers/
│   ├── attendee_registrations_controller.rb ✓
│   └── counsellors_controller.rb ✓
├── models/
│   ├── attendee_registration.rb ✓
│   ├── attendee.rb ✓
│   └── counsellor.rb ✓
└── views/
    ├── attendee_registrations/
    │   ├── new.html.erb ✓ (main form)
    │   └── _attendee_fields.html.erb ✓ (child partial)
    └── counsellors/
        └── new.html.erb 📝 (needs customization)

db/migrate/
├── 20241216000001_devise_create_users.rb ✓
├── 20251217061700_create_attendee_registrations.rb ✓
├── 20251217061723_create_attendees.rb ✓
└── 20251217061731_create_counsellors.rb 📝
```

## Quick Reference

| What | Model | Controller | View | Route |
|------|-------|------------|------|-------|
| Admin Login | User | Users::RegistrationsController | devise/registrations/new | /users/sign_up |
| Kid Registration | AttendeeRegistration + Attendee | AttendeeRegistrationsController | attendee_registrations/new | /attendees/register |
| Counsellor | Counsellor | CounsellorsController | counsellors/new | /counsellors/register |

---

**The key insight**: One registration form creates **1 parent record + N child records** in a single transaction!

