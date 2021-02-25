// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

// import Rails from "@rails/ujs"
// Rails.start()
// The above is currently breaking form submissions when using Turbo. Not sure what else it does
// but probably worth leaving this note.

require('shopify_app')

import '@hotwired/turbo-rails'
import * as ActiveStorage from '@rails/activestorage'
import 'channels'
import 'controllers'
import '../components'

import '@shopify/polaris/dist/styles.css'

ActiveStorage.start()
