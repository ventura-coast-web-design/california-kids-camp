// Burger Menu Functionality
document.addEventListener('DOMContentLoaded', () => {
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
  
  if (burgerMenu && navMenu) {
    // Toggle menu on burger click
    burgerMenu.addEventListener('click', (e) => {
      e.stopPropagation()
      burgerMenu.classList.toggle('is-active')
      navMenu.classList.toggle('is-active')
    })

    // Close menu when clicking on a navigation link
    const navLinks = document.querySelectorAll('.nav-link')
    navLinks.forEach(link => {
      link.addEventListener('click', () => {
        burgerMenu.classList.remove('is-active')
        navMenu.classList.remove('is-active')
        closeDropdown()
      })
    })

    // Close menu when clicking outside
    document.addEventListener('click', (event) => {
      const isClickInsideNav = navMenu.contains(event.target)
      const isClickOnBurger = burgerMenu.contains(event.target)
      
      if (!isClickInsideNav && !isClickOnBurger && navMenu.classList.contains('is-active')) {
        burgerMenu.classList.remove('is-active')
        navMenu.classList.remove('is-active')
        closeDropdown()
      }
    })

    // Close menu on window resize if switching to desktop view
    window.addEventListener('resize', () => {
      if (window.innerWidth >= 768) {
        burgerMenu.classList.remove('is-active')
        navMenu.classList.remove('is-active')
        closeDropdown()
      }
    })
  }

  // Register dropdown functionality
  
  if (registerDropdown && registerDropdownMenu) {
    registerDropdown.addEventListener('click', (e) => {
      e.stopPropagation()
      const isExpanded = registerDropdown.getAttribute('aria-expanded') === 'true'
      registerDropdown.setAttribute('aria-expanded', !isExpanded)
      registerDropdownMenu.classList.toggle('is-active')
    })

    // Close dropdown when clicking outside
    document.addEventListener('click', (event) => {
      const isClickInsideDropdown = registerDropdown.contains(event.target) || 
                                    registerDropdownMenu.contains(event.target)
      
      if (!isClickInsideDropdown && registerDropdownMenu.classList.contains('is-active')) {
        closeDropdown()
      }
    })

    // Close dropdown when clicking on a dropdown item
    const dropdownItems = registerDropdownMenu.querySelectorAll('.dropdown-item')
    dropdownItems.forEach(item => {
      item.addEventListener('click', () => {
        closeDropdown()
      })
    })

    // Close dropdown on escape key
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && registerDropdownMenu.classList.contains('is-active')) {
        closeDropdown()
      }
    })
  }

  // Smooth scroll for anchor links
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
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
    })
  })
})

