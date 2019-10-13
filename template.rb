=begin
Author: By Association Only
Author URI: https://byassociationonly.com
Instructions: $ rails new myapp -d postgresql --webpack=react -m https://raw.githubusercontent.com/baoagency/BAO-Shopify-App-Template/master/template.rb
=end

APPLICATION_BEFORE = "\n    # Settings in config/environments/* take precedence over those specified here."

def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

def add_gems
  gem "shopify_app", "~>11.2.0"
  gem "react-rails"
  gem "sidekiq"
  gem "sidekiq-throttled"
  gem "sidekiq-statistic"
  gem "sidekiq-status"
  gem "sidekiq-failures"
  gem 'friendly_id'
  gem 'rack-cors'
end

def initial_setup
  insert_into_file "config/application.rb",
    "config.generators.stylesheets = false\n",
    before: APPLICATION_BEFORE
  insert_into_file "config/application.rb",
    "    config.generators.system_tests = false\n",
    before: APPLICATION_BEFORE
end

def initialise_shopify_app
  copy_file ".env"
  copy_file ".env.example"

  generate "shopify_app"
end

def add_react_rails
  run "yarn add @shopify/app-bridge-react @shopify/polaris react_ujs"

  insert_into_file "config/application.rb",
    "    config.react.camelize_props = true\n",
    before: APPLICATION_BEFORE
  insert_into_file "config/application.rb",
    "    Jbuilder.key_format camelize: :lower\n",
    before: APPLICATION_BEFORE

  home_controller_content = <<-RUBY
    component: 'Containers/Home', props: {
      apiKey: ShopifyApp.configuration.api_key,
      shopOrigin: @shop_session.url,
    }
  RUBY
  insert_into_file "app/controllers/home_controller.rb",
    "\n#{home_controller_content}",
    after: "@webhooks = ShopifyAPI::Webhook.find(:all)"
end

def add_cors
  cors_content = <<-RUBY
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [:get, :post, :patch, :options, :delete]
      end
    end
  RUBY
  insert_into_file "config/application.rb",
    "#{cors_content}\n",
    before: APPLICATION_BEFORE
end

def add_sidekiq
  insert_into_file "config/application.rb",
    "config.active_job.queue_adapter = :sidekiq\n",
    before: APPLICATION_BEFORE
  insert_into_file "config/application.rb",
    "Sidekiq.configure_server { |c| c.redis = { url: ENV['REDIS_URL'] } }\n",
    before: APPLICATION_BEFORE

  route_content = <<-RUBY
     require 'sidekiq/web'
    # require 'sidekiq/throttled/web'
  
    # Sidekiq::Throttled::Web.enhance_queues_tab!
  
    mount Sidekiq::Web => '/sidekiq'
  RUBY
  insert_into_file "config/routes.rb",
    "#{route_content}\n",
    after: "mount ShopifyApp::Engine, at: '/'\n"
end

def add_js_linting
  run "yarn add -D @by-association-only/eslint-config-unisian"
  package_json_content = <<-PACKAGE
  "scripts": {
    "lint:js": "eslint 'app/javascript/**/*.js' --fix",
    "precommit": "lint-staged"
  },
  "husky": {
    "hooks": {
      "pre-commit": "lint-staged"
    }
  },
  "lint-staged": {
    "*.js": [
      "prettier-standard",
      "eslint --fix",
      "git add"
    ]
  },
  PACKAGE

  inject_into_file "./package.json",
    "#{package_json_content}",
    before: '  "dependencies": {'

  run "yarn add -D husky lint-staged"
end

def add_foreman
  copy_file "Procfile"
  copy_file "Procfile.dev"
end

def add_friendly_id
  generate "friendly_id"
end

def copy_templates
  directory "app", force: true
end

source_paths
add_gems

after_bundle do
  initial_setup
  initialise_shopify_app
  add_react_rails
  add_js_linting
  add_sidekiq
  add_foreman
  add_friendly_id
  add_cors

  copy_templates

  rails_command "db:create"
  rails_command "db:migrate"

  git :init
  git add: "."
  git commit: %Q{ -m "Initial commit" }

  say
  say "Kickoff app successfully created! 👍", :green
  say
  say "Switch to your app by running:"
  say "$ cd #{app_name}", :yellow
  say
  say "Then run:"
  say "$ foreman start -f Procfile.dev", :green
end
