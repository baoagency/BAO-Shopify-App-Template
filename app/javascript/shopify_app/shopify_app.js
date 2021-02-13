import { Turbo } from '@hotwired/turbo-rails'
import { getSessionToken } from '@shopify/app-bridge-utils'

async function retrieveToken (app) {
  window.sessionToken = await getSessionToken(app)
}

function keepRetrievingToken (app) {
  setInterval(() => retrieveToken(app), 2000)
}

document.addEventListener('DOMContentLoaded', async () => {
  const data = document.getElementById('shopify-app-init').dataset
  const AppBridge = window['app-bridge']
  const createApp = AppBridge.default
  window.app = createApp({
    apiKey: data.apiKey,
    shopOrigin: data.shopOrigin,
  })

  const actions = AppBridge.actions
  const TitleBar = actions.TitleBar
  TitleBar.create(window.app, {
    title: data.page,
  })

  // Wait for a session token before trying to load an authenticated page
  await retrieveToken(window.app)

  // Redirect to the requested page
  Turbo.visit(data.loadPath)

  // Keep retrieving a session token periodically
  keepRetrievingToken(window.app)
})

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
