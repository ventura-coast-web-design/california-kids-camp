// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "menu"

// Suppress harmless Google Maps extension errors
// These occur when browser extensions try to interact with Google Maps iframes
// The error happens when an extension sends a message to the iframe but the page navigates away
window.addEventListener('unhandledrejection', (event) => {
  const errorMessage = event.reason?.message || String(event.reason || '')
  // Suppress the specific Google Maps extension error
  if (errorMessage.includes('message channel closed') && 
      errorMessage.includes('asynchronous response')) {
    // Prevent the error from being logged to console
    event.preventDefault()
  }
})
