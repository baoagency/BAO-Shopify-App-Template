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

def copy_directories
  directory "app", force: true
  directory "frontend", force: true
end

def add_graphql
  inside("frontend") do
    run "npm i graphql-request"
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

def finish
  inside("../") do
    git add: "."
    git commit: %( -m "BAO'd 🤙" )
  end
end

add_template_repository_to_source_path
copy_directories
add_graphql
setup_frontend
add_annotate
finish
