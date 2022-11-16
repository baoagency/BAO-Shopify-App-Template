# frozen_string_literal: true

# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
require "fileutils"
require "shellwords"

def add_template_repository_to_source_path
  if __FILE__.match?(%r{\Ahttps?://})
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

def copy_files
  directory "app", force: true
  directory "config", force: true
  directory "frontend", force: true

  copy_file '.graphqlconfig'
  copy_file 'generate-shopify-graphql-types.js'
  copy_file 'schema.graphql'
end

def edit_base_files
  insert_into_file(
    "config/application.rb",
    "    Jbuilder.key_format camelize: :lower\n\n",
    before: "    # Configuration for the application, engines, and railties goes here."
  )
end

def add_graphql
  inside("frontend") do
    run "npm i graphql-request graphql @shopify/admin-graphql-api-utilities"
  end

  route 'post "/api/graphql", to: "graphql#proxy"'
end

def setup_frontend
  inside("frontend") do
    run "npm i -D @types/node"
  end
end

def add_annotate
  gem "annotate", group: [:development]

  generate "annotate:install"
end

def setup_api_routes
  route_content = <<-ROUTE
    resources :shops, controller: "api/v1/shops", path: "api/shops", only: [:show], param: :shopify_domain do
      collection do
        get :me
      end
    end
  ROUTE

  route route_content.to_s
end

def finish
  inside("../") do
    git add: "."
    git commit: %( -m "BAO'd 🤙" )
  end
end

add_template_repository_to_source_path
copy_files
edit_base_files
add_graphql
setup_frontend
add_annotate
setup_api_routes
finish
