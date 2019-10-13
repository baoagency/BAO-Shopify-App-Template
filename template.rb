=begin
Author: By Association Only
Author URI: https://byassociationonly.com
Instructions: $ rails new myapp -d postgresql --webpack=react -m https://raw.githubusercontent.com/baoagency/BAO-Shopify-App-Template/master/template.rb
=end

APPLICATION_BEFORE = "\n    # Settings in config/environments/* take precedence over those specified here."

# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
require "fileutils"
require "shellwords"

def add_template_repository_to_source_path
  if __FILE__ =~ %r{\Ahttps?://}
    require "tmpdir"
    source_paths.unshift(tempdir = Dir.mktmpdir("rails-template-"))
    at_exit { FileUtils.remove_entry(tempdir) }
    git clone: [
      "--quiet",
      "https://github.com/baoagency/BAO-Shopify-App-Template.git",
      tempdir
    ].map(&:shellescape).join(" ")

    if (branch = __FILE__[%r{rails-template/(.+)/template.rb}, 1])
      Dir.chdir(tempdir) { git checkout: branch }
    end
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

def add_gems
  gem "shopify_app", "~>11.2.0"
  gem "react-rails"
  gem "sidekiq"
  gem "sidekiq-throttled"
  gem "sidekiq-statistic"
  gem "sidekiq-status"
  gem "sidekiq-failures"
  gem "friendly_id"
  gem "rack-cors"
  gem "annotate", group: [:development]
end

def initial_setup
  insert_into_file "config/application.rb",
    "config.generators.stylesheets = false\n",
    before: APPLICATION_BEFORE
  insert_into_file "config/application.rb",
    "    config.generators.system_tests = false\n",
    before: APPLICATION_BEFORE

  generate "annotate:install"
end

def initialise_shopify_app
  template "example.env.tt"
  template "example.env.tt", ".env"

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
  copy_file ".eslintrc.js"
  run "yarn add -D @by-association-only/eslint-config-unisian eslint eslint-plugin-react"
  package_json_content = <<-PACKAGE
  "scripts": {
    "lint:js": "eslint 'app/javascript/**/*.js' --fix"
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

add_template_repository_to_source_path
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

  rails_command "db:drop"
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
