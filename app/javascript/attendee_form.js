// Attendee registration form functionality
(function() {
  'use strict';

  // Store handlers for cleanup
  let handlers = {
    guardian2Change: null,
    addButtonClick: null,
    removeButtonClick: null
  };

  // Track if form is initialized to prevent duplicate initialization
  let isInitialized = false;

  // Initialize form functionality
  function initializeAttendeeForm() {
    const form = document.querySelector('form[action*="attendee_registrations"]');
    if (!form) {
      isInitialized = false;
      return;
    }

    // Prevent duplicate initialization
    if (isInitialized) return;
    isInitialized = true;

    // Reset attendee index based on current form state
    const container = document.getElementById('attendees-container');
    const existingAttendees = container ? container.querySelectorAll('.attendee-form-group').length : 0;
    const initialCount = parseInt(form.dataset.initialAttendeeCount || '0') || existingAttendees;
    let attendeeIndex = initialCount;

    // Toggle Guardian 2 address fields
    const sameAddressCheckbox = document.querySelector('#attendee_registration_guardian_2_same_address');
    const guardian2Address = document.getElementById('guardian-2-address');
    
    // Cleanup previous handler
    if (handlers.guardian2Change && sameAddressCheckbox) {
      sameAddressCheckbox.removeEventListener('change', handlers.guardian2Change);
    }
    
    if (sameAddressCheckbox && guardian2Address) {
      handlers.guardian2Change = function() {
        guardian2Address.style.display = this.checked ? 'none' : 'block';
      };
      sameAddressCheckbox.addEventListener('change', handlers.guardian2Change);
      
      // Set initial state
      guardian2Address.style.display = sameAddressCheckbox.checked ? 'none' : 'block';
    }

    // Dynamic attendee form management
    const addButton = document.getElementById('add-attendee-btn');
    const attendeesContainer = document.getElementById('attendees-container');
    
    if (!addButton || !attendeesContainer) return;
    
    // Cleanup previous handlers
    if (handlers.addButtonClick) {
      addButton.removeEventListener('click', handlers.addButtonClick);
    }
    if (handlers.removeButtonClick) {
      attendeesContainer.removeEventListener('click', handlers.removeButtonClick);
    }
    
    handlers.addButtonClick = function(e) {
      e.preventDefault();
      const newId = new Date().getTime();
      const template = `
        <div class="attendee-form-group" style="border: 1px solid #d1d5db; border-radius: 8px; padding: 12px; margin-bottom: 12px; background-color: #f9fafb;">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
            <h4 style="font-size: 16px; font-weight: 600; color: #374151;">Child ${attendeeIndex + 1}</h4>
            <button type="button" class="remove-attendee-btn" style="color: #dc2626; font-size: 14px; background: none; border: none; cursor: pointer;">Remove</button>
          </div>

          <div class="form-grid form-grid-2">
            <div class="form-group">
              <label class="form-label">First Name</label>
              <input type="text" name="attendee_registration[attendees_attributes][${newId}][first_name]" class="form-control" required />
            </div>

            <div class="form-group">
              <label class="form-label">Last Name</label>
              <input type="text" name="attendee_registration[attendees_attributes][${newId}][last_name]" class="form-control" required />
            </div>

            <div class="form-group">
              <label class="form-label">Date of Birth</label>
              <input type="date" name="attendee_registration[attendees_attributes][${newId}][date_of_birth]" class="form-control" required max="${new Date().toISOString().split('T')[0]}" title="Date of birth must be in the past" />
            </div>

            <div class="form-group">
              <label class="form-label">Gender</label>
              <select name="attendee_registration[attendees_attributes][${newId}][gender]" class="form-control">
                <option value="">Select...</option>
                <option value="Male">Male</option>
                <option value="Female">Female</option>
              </select>
            </div>

            <div class="form-group">
              <label class="form-label">T-Shirt Size</label>
              <select name="attendee_registration[attendees_attributes][${newId}][tshirt_size]" class="form-control">
                <option value="">Select...</option>
                <option value="Youth S">Youth S</option>
                <option value="Youth M">Youth M</option>
                <option value="Youth L">Youth L</option>
                <option value="Youth XL">Youth XL</option>
                <option value="Adult S">Adult S</option>
                <option value="Adult M">Adult M</option>
                <option value="Adult L">Adult L</option>
                <option value="Adult XL">Adult XL</option>
                <option value="Adult XXL">Adult XXL</option>
              </select>
            </div>

            <div class="form-group">
              <label style="display: flex; align-items: center;">
                <input type="checkbox" name="attendee_registration[attendees_attributes][${newId}][piano]" value="1" style="margin-right: 8px;" />
                <span style="font-size: 14px;">This attendee plays piano</span>
              </label>
            </div>

            <div class="form-group" style="grid-column: 1 / -1;">
              <div class="form-grid form-grid-3">
                <div class="form-group">
                  <label class="form-label">Phone Number</label>
                  <input type="tel" name="attendee_registration[attendees_attributes][${newId}][phone]" class="form-control" required pattern="[\\d\\s\\-\\(\\)\\+\\.]+" title="Please enter a valid phone number" />
                </div>

                <div class="form-group">
                  <label class="form-label">Email</label>
                  <input type="email" name="attendee_registration[attendees_attributes][${newId}][email]" class="form-control" required />
                </div>

                <div class="form-group">
                  <label class="form-label">Ecclesia</label>
                  <input type="text" name="attendee_registration[attendees_attributes][${newId}][ecclesia]" class="form-control" required />
                </div>
              </div>
            </div>

            <div class="form-group" style="grid-column: 1 / -1;">
              <label style="display: flex; align-items: center;">
                <input type="checkbox" class="attendee-same-address-checkbox" checked style="margin-right: 8px;" />
                <span style="font-size: 14px;">Same address as primary guardian</span>
              </label>
            </div>

            <div class="attendee-address-fields" style="grid-column: 1 / -1; display: none;">
              <h5 style="font-weight: 600; margin-bottom: 8px; font-size: 14px;">Address</h5>

              <div class="form-group" style="grid-column: 1 / -1;">
                <label class="form-label">Address Line 1</label>
                <input type="text" name="attendee_registration[attendees_attributes][${newId}][address_line_1]" class="form-control" />
              </div>

              <div class="form-group" style="grid-column: 1 / -1;">
                <label class="form-label">Address Line 2 (Optional)</label>
                <input type="text" name="attendee_registration[attendees_attributes][${newId}][address_line_2]" class="form-control" />
              </div>

              <div class="form-group">
                <label class="form-label">City</label>
                <input type="text" name="attendee_registration[attendees_attributes][${newId}][city]" class="form-control" />
              </div>

              <div class="form-group">
                <label class="form-label">State</label>
                <input type="text" name="attendee_registration[attendees_attributes][${newId}][state]" class="form-control" maxlength="2" pattern="[A-Z]{2}" placeholder="CA" title="Please enter a 2-letter state code (e.g., CA)" />
              </div>

              <div class="form-group">
                <label class="form-label">ZIP Code</label>
                <input type="text" name="attendee_registration[attendees_attributes][${newId}][zip]" class="form-control" pattern="\\d{5}(-\\d{4})?" title="Please enter a valid ZIP code (e.g., 12345 or 12345-6789)" />
              </div>
            </div>

            <div class="form-group" style="grid-column: 1 / -1;">
              <label class="form-label">Medical Conditions</label>
              <textarea name="attendee_registration[attendees_attributes][${newId}][medical_conditions]" rows="2" class="form-control" required placeholder="Any medical conditions we should be aware of..."></textarea>
            </div>

            <div class="form-group" style="grid-column: 1 / -1;">
              <label class="form-label">Dietary Restrictions</label>
              <textarea name="attendee_registration[attendees_attributes][${newId}][dietary_restrictions]" rows="2" class="form-control" required placeholder="Any dietary restrictions..."></textarea>
            </div>

            <div class="form-group" style="grid-column: 1 / -1;">
              <label class="form-label">Allergies</label>
              <textarea name="attendee_registration[attendees_attributes][${newId}][allergies]" rows="2" class="form-control" required placeholder="Any allergies..."></textarea>
            </div>

            <div class="form-group" style="grid-column: 1 / -1;">
              <label class="form-label">Special Needs</label>
              <textarea name="attendee_registration[attendees_attributes][${newId}][special_needs]" rows="2" class="form-control" placeholder="Any special needs or accommodations required..."></textarea>
            </div>

            <div class="form-group" style="grid-column: 1 / -1;">
              <label class="form-label">Additional Notes</label>
              <textarea name="attendee_registration[attendees_attributes][${newId}][notes]" rows="2" class="form-control" placeholder="Any additional information about this child..."></textarea>
            </div>
          </div>
        </div>
      `;
      
      attendeesContainer.insertAdjacentHTML('beforeend', template);
      attendeeIndex++;
      
      // Update child numbers
      updateChildNumbers();
      
      // Set up address checkbox handler for the newly added attendee
      const newAttendeeGroup = attendeesContainer.lastElementChild;
      setupAttendeeAddressCheckbox(newAttendeeGroup);
    };
    
    addButton.addEventListener('click', handlers.addButtonClick);
    
    // Remove attendee handler (event delegation)
    handlers.removeButtonClick = function(e) {
      if (e.target.classList.contains('remove-attendee-btn')) {
        e.preventDefault();
        const attendeeCount = attendeesContainer.querySelectorAll('.attendee-form-group').length;
        
        if (attendeeCount > 1) {
          e.target.closest('.attendee-form-group').remove();
          updateChildNumbers();
        } else {
          alert('You must register at least one child.');
        }
      }
    };
    
    attendeesContainer.addEventListener('click', handlers.removeButtonClick);
    
    function updateChildNumbers() {
      const attendeeForms = attendeesContainer.querySelectorAll('.attendee-form-group');
      attendeeForms.forEach((form, index) => {
        const header = form.querySelector('h4');
        if (header) {
          header.textContent = `Child ${index + 1}`;
        }
      });
    }
    
    // Set up address checkbox handlers for all existing attendees
    setupAllAttendeeAddressCheckboxes();
  }
  
  // Function to copy guardian 1 address to attendee address fields
  function copyGuardian1AddressToAttendee(attendeeGroup) {
    const guardian1AddressLine1 = document.querySelector('#attendee_registration_guardian_1_address_line_1');
    const guardian1AddressLine2 = document.querySelector('#attendee_registration_guardian_1_address_line_2');
    const guardian1City = document.querySelector('#attendee_registration_guardian_1_city');
    const guardian1State = document.querySelector('#attendee_registration_guardian_1_state');
    const guardian1Zip = document.querySelector('#attendee_registration_guardian_1_zip');
    
    if (!attendeeGroup) return;
    
    const attendeeAddressLine1 = attendeeGroup.querySelector('input[name*="[address_line_1]"]');
    const attendeeAddressLine2 = attendeeGroup.querySelector('input[name*="[address_line_2]"]');
    const attendeeCity = attendeeGroup.querySelector('input[name*="[city]"]');
    const attendeeState = attendeeGroup.querySelector('input[name*="[state]"]');
    const attendeeZip = attendeeGroup.querySelector('input[name*="[zip]"]');
    
    if (guardian1AddressLine1 && attendeeAddressLine1) {
      attendeeAddressLine1.value = guardian1AddressLine1.value || '';
    }
    if (guardian1AddressLine2 && attendeeAddressLine2) {
      attendeeAddressLine2.value = guardian1AddressLine2.value || '';
    }
    if (guardian1City && attendeeCity) {
      attendeeCity.value = guardian1City.value || '';
    }
    if (guardian1State && attendeeState) {
      attendeeState.value = guardian1State.value || '';
    }
    if (guardian1Zip && attendeeZip) {
      attendeeZip.value = guardian1Zip.value || '';
    }
  }
  
  // Function to set up address checkbox handler for a single attendee group
  function setupAttendeeAddressCheckbox(attendeeGroup) {
    if (!attendeeGroup) return;
    
    const checkbox = attendeeGroup.querySelector('.attendee-same-address-checkbox');
    const addressFields = attendeeGroup.querySelector('.attendee-address-fields');
    
    if (!checkbox || !addressFields) return;
    
    // Get address input fields
    const addressLine1 = attendeeGroup.querySelector('input[name*="[address_line_1]"]');
    const city = attendeeGroup.querySelector('input[name*="[city]"]');
    const state = attendeeGroup.querySelector('input[name*="[state]"]');
    const zip = attendeeGroup.querySelector('input[name*="[zip]"]');
    
    // Function to toggle required attributes
    function toggleRequiredFields(required) {
      if (addressLine1) addressLine1.required = required;
      if (city) city.required = required;
      if (state) state.required = required;
      if (zip) zip.required = required;
    }
    
    // Set initial state
    addressFields.style.display = checkbox.checked ? 'none' : 'block';
    toggleRequiredFields(!checkbox.checked);
    
    // If checkbox is checked, copy guardian 1 address
    if (checkbox.checked) {
      copyGuardian1AddressToAttendee(attendeeGroup);
    }
    
    // Handle checkbox change
    checkbox.addEventListener('change', function() {
      if (this.checked) {
        addressFields.style.display = 'none';
        toggleRequiredFields(false);
        copyGuardian1AddressToAttendee(attendeeGroup);
      } else {
        addressFields.style.display = 'block';
        toggleRequiredFields(true);
      }
    });
  }
  
  // Function to set up address checkbox handlers for all attendees
  function setupAllAttendeeAddressCheckboxes() {
    const attendeesContainer = document.getElementById('attendees-container');
    if (!attendeesContainer) return;
    
    const attendeeGroups = attendeesContainer.querySelectorAll('.attendee-form-group');
    attendeeGroups.forEach(function(group) {
      setupAttendeeAddressCheckbox(group);
    });
  }
  
  // Listen to guardian 1 address changes and update attendee addresses if checkbox is checked
  function setupGuardian1AddressListeners() {
    const guardian1Fields = [
      '#attendee_registration_guardian_1_address_line_1',
      '#attendee_registration_guardian_1_address_line_2',
      '#attendee_registration_guardian_1_city',
      '#attendee_registration_guardian_1_state',
      '#attendee_registration_guardian_1_zip'
    ];
    
    guardian1Fields.forEach(function(selector) {
      const field = document.querySelector(selector);
      if (field) {
        // Remove existing listeners by cloning the field
        const newField = field.cloneNode(true);
        field.parentNode.replaceChild(newField, field);
        
        newField.addEventListener('input', function() {
          const attendeesContainer = document.getElementById('attendees-container');
          if (!attendeesContainer) return;
          
          const attendeeGroups = attendeesContainer.querySelectorAll('.attendee-form-group');
          attendeeGroups.forEach(function(group) {
            const checkbox = group.querySelector('.attendee-same-address-checkbox');
            if (checkbox && checkbox.checked) {
              copyGuardian1AddressToAttendee(group);
            }
          });
        });
      }
    });
  }
  
  // Set up guardian 1 address listeners when form initializes
  function setupListeners() {
    setTimeout(setupGuardian1AddressListeners, 100);
  }

  // Initialize on DOMContentLoaded (for initial page load)
  function setupInitialization() {
    // Reset initialization flag when page changes
    isInitialized = false;
    initializeAttendeeForm();
    setupListeners();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setupInitialization);
  } else {
    setupInitialization();
  }

  // Initialize on Turbo load (for Turbo navigation)
  document.addEventListener('turbo:load', function() {
    isInitialized = false;
    setupInitialization();
  });

  // Reset on turbo:before-cache to allow re-initialization
  document.addEventListener('turbo:before-cache', function() {
    isInitialized = false;
  });
})();
