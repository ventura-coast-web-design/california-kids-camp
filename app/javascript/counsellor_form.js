// Counsellor registration form functionality
(function() {
  'use strict';

  // Store handlers for cleanup
  let handlers = {
    addButtonClick: null,
    removeCounsellorClick: null,
    squirtsClick: null,
    pairingChange: null,
    pairingInput: null,
    nameInput: null
  };

  // Track if form is initialized to prevent duplicate initialization
  let isInitialized = false;

  function initializeCounsellorForm() {
    const form = document.getElementById('counsellor-registration-form');
    if (!form) {
      isInitialized = false;
      return;
    }

    // Prevent duplicate initialization
    if (isInitialized) return;
    isInitialized = true;

    const counsellorsContainer = document.getElementById('counsellors-container');
    const addButton = document.getElementById('add-counsellor-btn');
    const template = document.getElementById('counsellor-fields-template');
    
    if (!counsellorsContainer || !addButton || !template) {
      isInitialized = false;
      return;
    }

    // Get initial counsellor index from data attribute or count existing forms
    const initialCount = parseInt(form.dataset.initialCounsellorCount || '0') || 
                         counsellorsContainer.querySelectorAll('.counsellor-form-group').length;
    let counsellorIndex = initialCount;

    // Cleanup previous handlers
    if (handlers.addButtonClick) {
      addButton.removeEventListener('click', handlers.addButtonClick);
    }
    if (handlers.removeCounsellorClick) {
      counsellorsContainer.removeEventListener('click', handlers.removeCounsellorClick);
    }
    if (handlers.squirtsClick) {
      counsellorsContainer.removeEventListener('click', handlers.squirtsClick);
    }
    if (handlers.pairingChange) {
      counsellorsContainer.removeEventListener('change', handlers.pairingChange);
    }
    if (handlers.pairingInput) {
      counsellorsContainer.removeEventListener('input', handlers.pairingInput);
    }
    if (handlers.nameInput) {
      counsellorsContainer.removeEventListener('input', handlers.nameInput);
    }

    // Add counselor button handler
    handlers.addButtonClick = function() {
      // Get template HTML - try content first, then innerHTML as fallback
      let templateHTML = '';
      if (template.content) {
        const tempDiv = document.createElement('div');
        tempDiv.appendChild(template.content.cloneNode(true));
        templateHTML = tempDiv.innerHTML;
      } else {
        templateHTML = template.innerHTML;
      }
      
      // Replace all placeholders with the current index
      let updatedHTML = templateHTML.replace(/\{INDEX\}/g, counsellorIndex);
      updatedHTML = updatedHTML.replace(/\{TIMESTAMP\}/g, Date.now());
      
      counsellorsContainer.insertAdjacentHTML('beforeend', updatedHTML);
      counsellorIndex++;
      updateCounsellorNumbers();
      // Setup same address checkboxes for the new form
      setTimeout(function() {
        setupSameAddressCheckboxes();
      }, 50);
    };
    
    addButton.addEventListener('click', handlers.addButtonClick);
    
    // Remove counselor handler (event delegation)
    handlers.removeCounsellorClick = function(e) {
      if (e.target.classList.contains('remove-counsellor-btn')) {
        e.preventDefault();
        const counsellorCount = counsellorsContainer.querySelectorAll('.counsellor-form-group').length;
        
        if (counsellorCount > 1) {
          e.target.closest('.counsellor-form-group').remove();
          updateCounsellorNumbers();
        } else {
          alert('You must register at least one counselor.');
        }
      }
    };
    
    counsellorsContainer.addEventListener('click', handlers.removeCounsellorClick);
    
    // Handle squirts add/remove
    handlers.squirtsClick = function(e) {
      if (e.target.classList.contains('add-squirt-btn')) {
        e.preventDefault();
        const counsellorGroup = e.target.closest('.counsellor-form-group');
        const squirtsContainer = counsellorGroup.querySelector('.squirts-container');
        const squirtTemplate = counsellorGroup.querySelector('.squirt-template');
        
        if (squirtsContainer && squirtTemplate) {
          // Find the index of this counselor by looking at the name attribute of the first input
          const firstInput = counsellorGroup.querySelector('input[name*="[first_name]"]');
          let counsellorIndexForSquirt = 0;
          if (firstInput) {
            const nameMatch = firstInput.name.match(/counsellors\[(\d+)\]/);
            if (nameMatch) {
              counsellorIndexForSquirt = parseInt(nameMatch[1]);
            }
          }
          
          // Get template HTML - try content first, then innerHTML as fallback
          let templateHTML = '';
          if (squirtTemplate.content) {
            const tempDiv = document.createElement('div');
            tempDiv.appendChild(squirtTemplate.content.cloneNode(true));
            templateHTML = tempDiv.innerHTML;
          } else {
            templateHTML = squirtTemplate.innerHTML;
          }
          
          // Replace placeholders
          let updatedHTML = templateHTML.replace(/\{INDEX\}/g, counsellorIndexForSquirt);
          updatedHTML = updatedHTML.replace(/\{TIMESTAMP\}/g, Date.now());
          
          squirtsContainer.insertAdjacentHTML('beforeend', updatedHTML);
        }
      }
      
      if (e.target.classList.contains('remove-squirt-btn')) {
        e.preventDefault();
        e.target.closest('.squirt-form-group').remove();
      }
    };
    
    counsellorsContainer.addEventListener('click', handlers.squirtsClick);
    
    function updateCounsellorNumbers() {
      const counsellorForms = counsellorsContainer.querySelectorAll('.counsellor-form-group');
      counsellorForms.forEach((form, index) => {
        const header = form.querySelector('h3');
        if (header) {
          header.textContent = `Counselor ${index + 1}'s Information:`;
        }
        
        // Update all input/select names to use the correct index
        form.querySelectorAll('input, select').forEach(function(input) {
          const name = input.name;
          if (name && name.includes('counsellors[')) {
            const newName = name.replace(/counsellors\[\d+\]/, `counsellors[${index}]`);
            input.name = newName;
          }
        });
      });
      
      // Update pairing dropdowns
      updatePairingDropdowns();
    }
    
    function updatePairingDropdowns() {
      const counsellorForms = counsellorsContainer.querySelectorAll('.counsellor-form-group');
      
      counsellorForms.forEach((form, currentIndex) => {
        const pairingSelect = form.querySelector('.pairing-select');
        if (!pairingSelect) return;
        
        // Store current selection
        const currentSelection = pairingSelect.value;
        
        // Clear and repopulate options
        pairingSelect.innerHTML = '<option value="">Choose a counselor...</option>';
        
        counsellorForms.forEach((otherForm, otherIndex) => {
          if (currentIndex !== otherIndex) {
            // Get the name from the other form
            const firstNameInput = otherForm.querySelector('input[name*="[first_name]"]');
            const lastNameInput = otherForm.querySelector('input[name*="[last_name]"]');
            let displayName = `Counselor ${otherIndex + 1}`;
            let fullName = '';
            
            if (firstNameInput && lastNameInput) {
              const firstName = firstNameInput.value || '';
              const lastName = lastNameInput.value || '';
              if (firstName || lastName) {
                fullName = `${firstName} ${lastName}`.trim();
                displayName = fullName || displayName;
              }
            }
            
            const option = document.createElement('option');
            option.value = fullName || `Counselor ${otherIndex + 1}`;
            option.textContent = displayName;
            option.dataset.index = otherIndex;
            if (currentSelection === option.value) {
              option.selected = true;
            }
            pairingSelect.appendChild(option);
          }
        });
        
        // Restore selection if it matches
        if (currentSelection) {
          pairingSelect.value = currentSelection;
        }
      });
    }
    
    // Handle pairing select change - clear name input when select is used
    handlers.pairingChange = function(e) {
      if (e.target.classList.contains('pairing-select')) {
        const form = e.target.closest('.counsellor-form-group');
        const nameInput = form.querySelector('.pairing-name-input');
        
        if (e.target.value) {
          // When a counselor is selected, clear the manual name input
          if (nameInput) nameInput.value = '';
        }
      }
    };
    
    counsellorsContainer.addEventListener('change', handlers.pairingChange);
    
    // Clear pairing select when name input is filled manually
    handlers.pairingInput = function(e) {
      if (e.target.classList.contains('pairing-name-input') && e.target.value.trim()) {
        const form = e.target.closest('.counsellor-form-group');
        const pairingSelect = form.querySelector('.pairing-select');
        if (pairingSelect) {
          pairingSelect.value = '';
        }
      }
    };
    
    counsellorsContainer.addEventListener('input', handlers.pairingInput);
    
    // Update pairing dropdowns when names change
    handlers.nameInput = function(e) {
      if (e.target.name && (e.target.name.includes('[first_name]') || e.target.name.includes('[last_name]'))) {
        updatePairingDropdowns();
      }
    };
    
    counsellorsContainer.addEventListener('input', handlers.nameInput);
    
    // Handle "Same address as previous counselor" checkbox
    function setupSameAddressCheckboxes() {
      const checkboxes = document.querySelectorAll('.same-address-checkbox:not([data-listener-attached])');
      checkboxes.forEach(function(checkbox) {
        checkbox.setAttribute('data-listener-attached', 'true');
        
        checkbox.addEventListener('change', function() {
          const currentGroup = this.closest('.counsellor-form-group');
          const addressFields = currentGroup.querySelectorAll('.address-field');
          
          if (this.checked) {
            // Find the previous counselor form
            const allGroups = Array.from(document.querySelectorAll('.counsellor-form-group'));
            const currentGroupIndex = allGroups.indexOf(currentGroup);
            
            if (currentGroupIndex > 0) {
              const previousGroup = allGroups[currentGroupIndex - 1];
              const previousAddressFields = previousGroup.querySelectorAll('.address-field');
              
              // Copy values from previous counselor
              addressFields.forEach(function(field, index) {
                const previousField = previousAddressFields[index];
                if (previousField) {
                  field.value = previousField.value;
                  
                  // Use readonly for text inputs, prevent changes for selects
                  if (field.tagName === 'SELECT') {
                    field.style.backgroundColor = '#f3f4f6';
                    field.style.cursor = 'not-allowed';
                    // Store locked value
                    const lockedValue = previousField.value;
                    field.setAttribute('data-locked-value', lockedValue);
                    // Prevent changes by reverting on change event
                    const preventChange = function(e) {
                      if (field.value !== lockedValue) {
                        field.value = lockedValue;
                      }
                    };
                    field.addEventListener('change', preventChange);
                    field.addEventListener('focus', function() {
                      this.blur();
                    });
                  } else {
                    field.readOnly = true;
                    field.style.backgroundColor = '#f3f4f6';
                    field.style.cursor = 'not-allowed';
                  }
                }
              });
              
              // Listen for changes in previous counselor's address fields
              previousAddressFields.forEach(function(prevField, prevIndex) {
                const updateListener = function() {
                  if (checkbox.checked) {
                    const currentField = addressFields[prevIndex];
                    if (currentField) {
                      currentField.value = prevField.value;
                      if (currentField.tagName === 'SELECT') {
                        currentField.setAttribute('data-locked-value', prevField.value);
                      }
                    }
                  }
                };
                
                // Add listener based on field type
                if (prevField.tagName === 'SELECT') {
                  prevField.addEventListener('change', updateListener);
                } else {
                  prevField.addEventListener('input', updateListener);
                }
              });
            }
          } else {
            // Uncheck: enable fields and clear them
            addressFields.forEach(function(field) {
              if (field.tagName === 'SELECT') {
                // Clone to remove all event listeners
                const newSelect = field.cloneNode(true);
                field.parentNode.replaceChild(newSelect, field);
                newSelect.style.backgroundColor = '';
                newSelect.style.cursor = '';
                newSelect.removeAttribute('data-locked-value');
                const defaultOption = newSelect.querySelector('option[value="United States of America"]');
                if (defaultOption) {
                  newSelect.value = 'United States of America';
                } else {
                  newSelect.value = '';
                }
              } else {
                field.readOnly = false;
                field.style.backgroundColor = '';
                field.style.cursor = '';
                field.value = '';
              }
            });
          }
        });
      });
    }
    
    // Setup checkboxes on page load
    setupSameAddressCheckboxes();
    
    // Initial update
    updateCounsellorNumbers();
  }

  // Initialize on DOMContentLoaded (for initial page load)
  function setupInitialization() {
    // Reset initialization flag when page changes
    isInitialized = false;
    initializeCounsellorForm();
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
