// Form validation utilities for registration forms

// Use event delegation for fields that may be replaced by Turbo
// This ensures listeners work even after Turbo navigation

// Auto-uppercase state fields
document.addEventListener('input', function(e) {
  const field = e.target;
  if (field.matches && (field.matches('input[pattern="[A-Z]{2}"]') || 
      (field.maxLength === 2 && field.placeholder && field.placeholder.includes('CA')))) {
    field.value = field.value.toUpperCase();
  }
});

// Format phone numbers as user types
document.addEventListener('input', function(e) {
  const field = e.target;
  if (field.matches && field.matches('input[type="tel"]')) {
    const currentValue = field.value;
    const digitsOnly = currentValue.replace(/\D/g, '');
    
    // Get cursor position before formatting
    const cursorPosition = field.selectionStart;
    const digitsBeforeCursor = currentValue.substring(0, cursorPosition).replace(/\D/g, '').length;
    
    // Format as (XXX) XXX-XXXX if 10 digits or less
    let formatted = '';
    if (digitsOnly.length <= 10) {
      if (digitsOnly.length > 0) {
        formatted += '(' + digitsOnly.slice(0, 3);
        if (digitsOnly.length > 3) {
          formatted += ') ' + digitsOnly.slice(3, 6);
          if (digitsOnly.length > 6) {
            formatted += '-' + digitsOnly.slice(6, 10);
          }
        }
      }
    } else {
      // For longer numbers (international), keep digits only
      formatted = digitsOnly;
    }
    
    // Only update if formatted value is different
    if (formatted !== currentValue) {
      field.value = formatted;
      
      // Calculate new cursor position
      // Count how many digits are before the cursor in the formatted string
      let newCursorPosition = 0;
      let digitsCounted = 0;
      
      for (let i = 0; i < formatted.length && digitsCounted < digitsBeforeCursor; i++) {
        if (/\d/.test(formatted[i])) {
          digitsCounted++;
        }
        newCursorPosition = i + 1;
      }
      
      // If we're at the end, put cursor at the end
      if (digitsCounted === digitsOnly.length) {
        newCursorPosition = formatted.length;
      }
      
      field.setSelectionRange(newCursorPosition, newCursorPosition);
    }
  }
});

// Format ZIP codes
document.addEventListener('input', function(e) {
  const field = e.target;
  if (field.matches && field.pattern && field.pattern.includes('\\d{5}')) {
    const currentValue = field.value;
    let value = currentValue.replace(/\D/g, '');
    
    // Check if already formatted correctly
    if (value.length > 5 && currentValue.match(/^\d{5}-\d{0,4}$/)) {
      return; // Already formatted, skip
    }
    
    if (value.length > 5) {
      value = `${value.slice(0, 5)}-${value.slice(5, 9)}`;
    }
    
    // Only update if value changed
    if (value && value !== currentValue) {
      field.value = value;
    }
  }
});

// Initialize form validation
function initializeFormValidation() {

  // Enhanced validation feedback - use event delegation for forms
  // This will work even after Turbo replaces content
}

// Form submit validation using event delegation
document.addEventListener('submit', function(e) {
  const form = e.target.closest('form');
  if (form) {
    if (!form.checkValidity()) {
      e.preventDefault();
      e.stopPropagation();
      
      // Find first invalid field and scroll to it
      const firstInvalid = form.querySelector(':invalid');
      if (firstInvalid) {
        firstInvalid.scrollIntoView({ behavior: 'smooth', block: 'center' });
        firstInvalid.focus();
        
        // Show custom error message
        showFieldError(firstInvalid);
      }
    }
    
    form.classList.add('was-validated');
  }
}, true); // Use capture phase

// Real-time validation feedback using event delegation
document.addEventListener('blur', function(e) {
  const field = e.target;
  if (field.matches && field.matches('input, select, textarea')) {
    validateField(field);
  }
}, true);

document.addEventListener('input', function(e) {
  const field = e.target;
  if (field.matches && field.matches('input, select, textarea') && field.classList.contains('is-invalid')) {
    validateField(field);
  }
}, true);

// Initialize on page load
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializeFormValidation);
} else {
  initializeFormValidation();
}

// Initialize on Turbo navigation (for Turbo Drive)
document.addEventListener('turbo:load', initializeFormValidation);
document.addEventListener('turbo:render', initializeFormValidation);
document.addEventListener('turbo:frame-load', initializeFormValidation);

function validateField(field) {
  if (field.checkValidity()) {
    field.classList.remove('is-invalid');
    field.classList.add('is-valid');
    removeFieldError(field);
  } else {
    field.classList.remove('is-valid');
    field.classList.add('is-invalid');
    showFieldError(field);
  }
}

function showFieldError(field) {
  removeFieldError(field);
  
  let errorMessage = field.validationMessage;
  
  // Custom error messages for specific patterns
  if (field.pattern) {
    if (field.pattern.includes('[A-Z]{2}')) {
      errorMessage = 'Please enter a 2-letter state code (e.g., CA)';
    } else if (field.pattern.includes('\\d{5}')) {
      errorMessage = 'Please enter a valid ZIP code (e.g., 12345 or 12345-6789)';
    } else if (field.pattern.includes('[\\d\\s\\-\\(\\)\\+\\.]+')) {
      errorMessage = 'Please enter a valid phone number';
    }
  }
  
  if (field.validity.valueMissing) {
    errorMessage = `${field.labels[0]?.textContent || 'This field'} is required`;
  } else if (field.validity.typeMismatch) {
    if (field.type === 'email') {
      errorMessage = 'Please enter a valid email address';
    }
  } else if (field.validity.rangeOverflow) {
    if (field.type === 'date') {
      errorMessage = 'Date must be in the past';
    }
  }
  
  const errorDiv = document.createElement('div');
  errorDiv.className = 'field-error';
  errorDiv.style.cssText = 'color: #dc2626; font-size: 12px; margin-top: 4px;';
  errorDiv.textContent = errorMessage;
  
  field.parentNode.appendChild(errorDiv);
}

function removeFieldError(field) {
  const errorDiv = field.parentNode.querySelector('.field-error');
  if (errorDiv) {
    errorDiv.remove();
  }
}

// Export for use in other scripts
window.FormValidation = {
  validateField,
  showFieldError,
  removeFieldError
};
