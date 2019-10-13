import React from 'react'
import PropTypes from 'prop-types'

import Container from './Base'

const Home = ({ apiKey, shopOrigin }) => {
  return (
    <Container apiKey={apiKey} shopOrigin={shopOrigin}>
      <p>This is the Home container</p>
    </Container>
  )
}

Home.propTypes = {
  apiKey: PropTypes.string,
  shopOrigin: PropTypes.string,
}

export default Home
