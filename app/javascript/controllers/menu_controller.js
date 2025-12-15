import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="menu"
export default class extends Controller {
  static targets = ["burger", "nav"]

  connect() {
    this.setupBurgerMenu()
    this.setupSmoothScroll()
  }

  setupBurgerMenu() {
    const burgerMenu = document.getElementById('burgerMenu')
    const navMenu = document.querySelector('.nav-menu')
    
    if (burgerMenu && navMenu) {
      burgerMenu.addEventListener('click', () => {
        burgerMenu.classList.toggle('is-active')
        navMenu.classList.toggle('is-active')
      })

      // Close menu when clicking on a link
      const navLinks = document.querySelectorAll('.nav-link')
      navLinks.forEach(link => {
        link.addEventListener('click', () => {
          burgerMenu.classList.remove('is-active')
          navMenu.classList.remove('is-active')
        })
      })

      // Close menu when clicking outside
      document.addEventListener('click', (event) => {
        const isClickInsideNav = navMenu.contains(event.target)
        const isClickOnBurger = burgerMenu.contains(event.target)
        
        if (!isClickInsideNav && !isClickOnBurger && navMenu.classList.contains('is-active')) {
          burgerMenu.classList.remove('is-active')
          navMenu.classList.remove('is-active')
        }
      })
    }
  }

  setupSmoothScroll() {
    // Smooth scroll for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
      anchor.addEventListener('click', function (e) {
        const href = this.getAttribute('href')
        
        // Don't prevent default for hash-only links
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
  }
}

