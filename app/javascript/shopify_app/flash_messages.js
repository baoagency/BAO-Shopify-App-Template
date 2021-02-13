document.addEventListener('turbo:load', () => {
  const flashData = JSON.parse(document.getElementById('shopify-app-flash').dataset.flash)
  const Toast = window['app-bridge'].actions.Toast

  if (flashData.notice) {
    Toast.create(window.app, {
      message: flashData.notice,
      duration: 5000,
    }).dispatch(Toast.Action.SHOW)
  }

  if (flashData.error) {
    Toast.create(window.app, {
      message: flashData.error,
      duration: 5000,
      isError: true,
    }).dispatch(Toast.Action.SHOW)
  }
})
