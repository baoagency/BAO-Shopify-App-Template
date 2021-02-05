import { Turbo } from '@hotwired/turbo-rails'
import { getSessionToken } from '@shopify/app-bridge-utils'

async function retrieveToken (app) {
  window.sessionToken = await getSessionToken(app)
}

function keepRetrievingToken (app) {
  setInterval(() => retrieveToken(app), 2000)
}

document.addEventListener('DOMContentLoaded', async () => {
  var data = document.getElementById('shopify-app-init').dataset
  var AppBridge = window['app-bridge']
  var createApp = AppBridge.default
  window.app = createApp({
    apiKey: data.apiKey,
    shopOrigin: data.shopOrigin,
  })

  var actions = AppBridge.actions
  var TitleBar = actions.TitleBar
  TitleBar.create(app, {
    title: data.page,
  })

  // Wait for a session token before trying to load an authenticated page
  await retrieveToken(app)

  // Redirect to the requested page
  Turbo.visit(data.loadPath)

  // Keep retrieving a session token periodically
  keepRetrievingToken(app)
})

document.addEventListener('turbo:before-fetch-request', e => {
  e.detail.fetchOptions.headers.Authorization = `Bearer ${window.sessionToken}`
})

document.addEventListener('turbo:visit', () => {
  const AppBridge = window['app-bridge']
  const actions = AppBridge.actions
  const History = actions.History
  const history = History.create(window.app)

  history.dispatch(History.Action.PUSH, window.location.pathname)
})
