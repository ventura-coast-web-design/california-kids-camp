// Form validation utilities for registration forms

// Auto-uppercase state fields
document.addEventListener('DOMContentLoaded', function() {
  const stateFields = document.querySelectorAll('input[pattern="[A-Z]{2}"], input[maxlength="2"][placeholder*="CA"]');
  stateFields.forEach(field => {
    field.addEventListener('input', function() {
      this.value = this.value.toUpperCase();
    });
  });

  // Format phone numbers as user types
  const phoneFields = document.querySelectorAll('input[type="tel"]');
  phoneFields.forEach(field => {
    field.addEventListener('input', function() {
      // Remove all non-digit characters for formatting
      let value = this.value.replace(/\D/g, '');
      
      // Format as (XXX) XXX-XXXX if 10 digits
      if (value.length === 10) {
        value = `(${value.slice(0, 3)}) ${value.slice(3, 6)}-${value.slice(6)}`;
      } else if (value.length > 10) {
        // Handle longer numbers (international)
        value = this.value; // Keep original if longer
      }
      
      // Only update if we have a value
      if (value) {
        this.value = value;
      }
    });
  });

  // Format ZIP codes
  const zipFields = document.querySelectorAll('input[pattern*="\\d{5}"]');
  zipFields.forEach(field => {
    field.addEventListener('input', function() {
      let value = this.value.replace(/\D/g, '');
      if (value.length > 5) {
        value = `${value.slice(0, 5)}-${value.slice(5, 9)}`;
      }
      if (value) {
        this.value = value;
      }
    });
  });

  // Enhanced validation feedback
  const forms = document.querySelectorAll('form');
  forms.forEach(form => {
    form.addEventListener('submit', function(e) {
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
    });

    // Real-time validation feedback
    const inputs = form.querySelectorAll('input, select, textarea');
    inputs.forEach(input => {
      input.addEventListener('blur', function() {
        validateField(this);
      });
      
      input.addEventListener('input', function() {
        if (this.classList.contains('is-invalid')) {
          validateField(this);
        }
      });
    });
  });
});

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
