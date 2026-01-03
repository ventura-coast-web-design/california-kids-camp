import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="directions"
export default class extends Controller {
  static targets = ["toggle", "content"]

  connect() {
    this.setupDropdowns()
  }

  setupDropdowns() {
    const toggles = this.element.querySelectorAll('.direction-toggle')
    
    toggles.forEach(toggle => {
      toggle.addEventListener('click', () => {
        const dropdown = toggle.closest('.direction-dropdown')
        const isExpanded = toggle.getAttribute('aria-expanded') === 'true'
        
        // Toggle aria-expanded
        toggle.setAttribute('aria-expanded', !isExpanded)
        
        // Toggle active class
        dropdown.classList.toggle('active')
      })
    })
  }
}

