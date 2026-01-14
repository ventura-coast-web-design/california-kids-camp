// Burger Menu Functionality
// Use Turbo lifecycle events to ensure this works with Turbo navigation

// Store handlers to allow cleanup
let handlers = {
  burgerClick: null,
  navLinkClicks: [],
  outsideClick: null,
  resize: null,
  dropdownClick: null,
  dropdownOutsideClick: null,
  dropdownItemClicks: [],
  escape: null,
  anchorClicks: []
}

const initializeMenu = () => {
  const burgerMenu = document.getElementById('burgerMenu')
  const navMenu = document.querySelector('.nav-menu')
  const registerDropdown = document.getElementById('registerDropdown')
  const registerDropdownMenu = document.getElementById('registerDropdownMenu')
  
  // Helper function to close dropdown
  const closeDropdown = () => {
    if (registerDropdown && registerDropdownMenu) {
      registerDropdown.setAttribute('aria-expanded', 'false')
      registerDropdownMenu.classList.remove('is-active')
    }
  }
  
  // Cleanup previous handlers
  if (handlers.burgerClick && burgerMenu) {
    burgerMenu.removeEventListener('click', handlers.burgerClick)
  }
  handlers.navLinkClicks.forEach(({ element, handler }) => {
    element.removeEventListener('click', handler)
  })
  handlers.navLinkClicks = []
  
  if (handlers.outsideClick) {
    document.removeEventListener('click', handlers.outsideClick)
  }
  if (handlers.resize) {
    window.removeEventListener('resize', handlers.resize)
  }
  if (handlers.dropdownClick && registerDropdown) {
    registerDropdown.removeEventListener('click', handlers.dropdownClick)
  }
  if (handlers.dropdownOutsideClick) {
    document.removeEventListener('click', handlers.dropdownOutsideClick)
  }
  handlers.dropdownItemClicks.forEach(({ element, handler }) => {
    element.removeEventListener('click', handler)
  })
  handlers.dropdownItemClicks = []
  if (handlers.escape) {
    document.removeEventListener('keydown', handlers.escape)
  }
  handlers.anchorClicks.forEach(({ element, handler }) => {
    element.removeEventListener('click', handler)
  })
  handlers.anchorClicks = []
  
  if (burgerMenu && navMenu) {
    // Toggle menu on burger click
    handlers.burgerClick = (e) => {
      e.stopPropagation()
      burgerMenu.classList.toggle('is-active')
      navMenu.classList.toggle('is-active')
    }
    burgerMenu.addEventListener('click', handlers.burgerClick)

    // Close menu when clicking on a navigation link
    const navLinks = document.querySelectorAll('.nav-link')
    navLinks.forEach(link => {
      // Only add listener if it's not the dropdown button
      if (link.id !== 'registerDropdown') {
        const handler = () => {
          burgerMenu.classList.remove('is-active')
          navMenu.classList.remove('is-active')
          closeDropdown()
        }
        link.addEventListener('click', handler)
        handlers.navLinkClicks.push({ element: link, handler })
      }
    })

    // Close menu when clicking outside
    handlers.outsideClick = (event) => {
      const isClickInsideNav = navMenu.contains(event.target)
      const isClickOnBurger = burgerMenu.contains(event.target)
      
      if (!isClickInsideNav && !isClickOnBurger && navMenu.classList.contains('is-active')) {
        burgerMenu.classList.remove('is-active')
        navMenu.classList.remove('is-active')
        closeDropdown()
      }
    }
    document.addEventListener('click', handlers.outsideClick)

    // Close menu on window resize if switching to desktop view
    handlers.resize = () => {
      if (window.innerWidth >= 768) {
        burgerMenu.classList.remove('is-active')
        navMenu.classList.remove('is-active')
        closeDropdown()
      }
    }
    window.addEventListener('resize', handlers.resize)
  }

  // Register dropdown functionality
  
  if (registerDropdown && registerDropdownMenu) {
    handlers.dropdownClick = (e) => {
      e.stopPropagation()
      const isExpanded = registerDropdown.getAttribute('aria-expanded') === 'true'
      registerDropdown.setAttribute('aria-expanded', !isExpanded)
      registerDropdownMenu.classList.toggle('is-active')
    }
    registerDropdown.addEventListener('click', handlers.dropdownClick)

    // Close dropdown when clicking outside
    handlers.dropdownOutsideClick = (event) => {
      const isClickInsideDropdown = registerDropdown.contains(event.target) || 
                                    registerDropdownMenu.contains(event.target)
      
      if (!isClickInsideDropdown && registerDropdownMenu.classList.contains('is-active')) {
        closeDropdown()
      }
    }
    document.addEventListener('click', handlers.dropdownOutsideClick)

    // Close dropdown when clicking on a dropdown item
    const dropdownItems = registerDropdownMenu.querySelectorAll('.dropdown-item')
    dropdownItems.forEach(item => {
      const handler = () => {
        closeDropdown()
      }
      item.addEventListener('click', handler)
      handlers.dropdownItemClicks.push({ element: item, handler })
    })

    // Close dropdown on escape key
    handlers.escape = (e) => {
      if (e.key === 'Escape' && registerDropdownMenu.classList.contains('is-active')) {
        closeDropdown()
      }
    }
    document.addEventListener('keydown', handlers.escape)
  }

  // Smooth scroll for anchor links
  const anchorLinks = document.querySelectorAll('a[href^="#"]')
  anchorLinks.forEach(anchor => {
    const handler = function (e) {
      const href = this.getAttribute('href')
      
      // Don't prevent default for hash-only links or contact forms
      if (href === '#' || href === '#!') {
        return
      }

      const target = document.querySelector(href)
      if (target) {
        e.preventDefault()
        const headerOffset = 80 // Height of sticky header
        const elementPosition = target.getBoundingClientRect().top
        const offsetPosition = elementPosition + window.pageYOffset - headerOffset

        window.scrollTo({
          top: offsetPosition,
          behavior: 'smooth'
        })
      }
    }
    anchor.addEventListener('click', handler)
    handlers.anchorClicks.push({ element: anchor, handler })
  })
}

// Initialize on DOMContentLoaded (for initial page load)
document.addEventListener('DOMContentLoaded', initializeMenu)

// Initialize on Turbo load (for Turbo navigation)
document.addEventListener('turbo:load', initializeMenu)

// Also initialize on turbo:render for compatibility
document.addEventListener('turbo:render', initializeMenu)

