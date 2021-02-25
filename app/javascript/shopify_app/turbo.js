import { Turbo } from '@hotwired/turbo-rails'
import { getSessionToken } from '@shopify/app-bridge-utils'

document.addEventListener('turbo:before-fetch-request', async e => {
  e.detail.fetchOptions.headers.Authorization = `Bearer ${window.sessionToken}`
})

// Force redirect via turbo using turbo_redirect_to helper in controller.
// Mandatory for Safari since it's loosing JWT token during 302 redirect.
document.addEventListener('turbo:before-fetch-response', (event) => {
  const response = event.detail.fetchResponse
  const status = response.statusCode
  const location = response.header('Location')

  if (status === 300 && location !== null) {
    event.preventDefault()

    Turbo.visit(location)
  }
})

document.addEventListener('turbo:render', () => {
  const forms = Array.from(document.querySelectorAll('form'))

  forms.forEach(form => {
    form.addEventListener('ajax:beforeSend', e => {
      const xhr = e.detail[0]

      xhr.setRequestHeader('Authorization', `Bearer ${window.sessionToken}`)
    })
  })
})

document.addEventListener('DOMContentLoaded', async () => {
  // Wait for a session token before trying to load an authenticated page
  await retrieveToken(window.app)

  // Keep retrieving a session token periodically
  keepRetrievingToken(window.app)

  // Redirect to the requested page when DOM loads
  const isInitialRedirect = true
  redirectThroughTurbo(isInitialRedirect)

  document.addEventListener('turbo:load', () => {
    redirectThroughTurbo()
  })

  // Helper functions
  function redirectThroughTurbo (isInitialRedirect = false) {
    const data = document.getElementById('shopify-app-init').dataset
    const validLoadPath = data && data.loadPath
    let shouldRedirect = false

    switch (isInitialRedirect) {
      case true:
        shouldRedirect = validLoadPath
        break
      case false:
        shouldRedirect = validLoadPath && data.loadPath !== '/landing' // Replace with the app's
        // home_path
        break
    }

    if (shouldRedirect) Turbo.visit(data.loadPath)
  }

  async function retrieveToken (app) {
    window.sessionToken = await getSessionToken(app)
  }

  function keepRetrievingToken (app) {
    setInterval(() => {
      retrieveToken(app)
    }, 2000)
  }
})
