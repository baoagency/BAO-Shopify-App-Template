import React from 'react'
import PropTypes from 'prop-types'
import translations from '@shopify/polaris/locales/en.json'
import { Provider } from '@shopify/app-bridge-react'
import { AppProvider } from '@shopify/polaris'


const Container = ({ apiKey, children, shopOrigin }) => {
  return (
    <AppProvider i18n={translations}>
      <Provider
        config={{
          apiKey: apiKey,
          shopOrigin: shopOrigin,
          forceRedirect: true
        }}
      >
        {children}
      </Provider>
    </AppProvider>
  )
}

Container.propTypes = {
  apiKey: PropTypes.string,
  shopOrigin: PropTypes.string,
  children: PropTypes.oneOfType([
    PropTypes.arrayOf(PropTypes.node),
    PropTypes.node
  ]).isRequired
}

export default Container
