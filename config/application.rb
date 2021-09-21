require File.expand_path('../boot', __FILE__)
require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
require 'zip'
require 'csv'

Bundler.require(*Rails.groups)
module AACT
  class Application < Rails::Application
    # This tells Rails to serve error pages from the Rails app itself (i.e. config/routes.rb),
    # rather than using static error pages in public/
    config.exceptions_app = self.routes

    config.time_zone = 'Eastern Time (US & Canada)'
    config.quiet_assets = true
    config.generators do |generate|
      generate.helper false
      generate.javascript_engine false
      generate.request_specs false
      generate.routing_specs false
      generate.stylesheets false
      generate.test_framework :rspec
      generate.view_specs false
    end
    config.active_record.schema_format = :sql
    config.action_controller.action_on_unpermitted_parameters = :raise

    AACT_DB_SUPER_USERNAME = ENV['AACT_DB_SUPER_USERNAME'] || 'ctti'

    AACT_PROCESS_SERVER    = ENV['AACT_PROCESS_SERVER']
    AACT_DB_VERSION        = ENV['AACT_DB_VERSION'] || 'uncertain'   # get this from the public database
    AACT_ADMIN_USERNAMES   = ENV['AACT_ADMIN_USERNAMES'] || ''       # User who can see restricted pages like technical documentation, users, etc.
    AACT_ADMIN_DIR         = ENV['AACT_ADMIN_DIR']                   # Directory where admin app resides
    AACT_VIEW_PASSWORD     = ENV['AACT_VIEW_PASSWORD']               # needed to get to use case edit view
    RACK_TIMEOUT           = ENV['RACK_TIMEOUT'] || 10
    if Rails.env == 'test'
      APPLICATION_HOST          = 'localhost'
      AACT_PUBLIC_HOSTNAME      = 'localhost'
      AACT_BACK_DATABASE_NAME   = 'aact_back_test'
      AACT_ADMIN_DATABASE_NAME  = 'aact_admin_test'
      AACT_PUBLIC_DATABASE_NAME = 'aact_test'
      AACT_BETA_DATABASE_NAME = 'aact_test'
      AACT_PUBLIC_IP_ADDRESS    = '127.0.0.1'
    else
      APPLICATION_HOST          = ENV['APPLICATION_HOST'] || 'localhost'
      AACT_PUBLIC_HOSTNAME      = ENV['AACT_PUBLIC_HOSTNAME'] || 'localhost'
      AACT_BACK_DATABASE_NAME   = ENV['AACT_BACK_DATABASE_NAME'] || 'aact_back'
      AACT_ADMIN_DATABASE_NAME  = ENV['AACT_ADMIN_DATABASE_NAME'] || 'aact_admin'
      AACT_PUBLIC_DATABASE_NAME = ENV['AACT_PUBLIC_DATABASE_NAME'] || 'aact'
      AACT_BETA_DATABASE_NAME = ENV['AACT_BETA_DATABASE_NAME'] || 'aact_beta'
      AACT_PUBLIC_IP_ADDRESS    = ENV['AACT_PUBLIC_IP_ADDRESS'] || '127.0.0.1'
    end
    AACT_BACK_DATABASE_URL   = "postgres://#{AACT_DB_SUPER_USERNAME}@#{APPLICATION_HOST}:5432/#{AACT_BACK_DATABASE_NAME}"
    AACT_ADMIN_DATABASE_URL  = "postgres://#{AACT_DB_SUPER_USERNAME}@#{APPLICATION_HOST}:5432/#{AACT_ADMIN_DATABASE_NAME}"

    # public database connection
    PUBLIC_DB_HOST = ENV['PUBLIC_DB_HOST'] || 'localhost'
    PUBLIC_DB_PORT = ENV['PUBLIC_DB_PORT'] || 5432
    PUBLIC_DB_NAME = ENV['PUBLIC_DB_NAME'] || 'aact'
    PUBLIC_DB_USER = ENV['PUBLIC_DB_USER'] || 'ctti'
    PUBLIC_DB_PASS = ENV['PUBLIC_DB_PASS'] || ''
    AACT_PUBLIC_DATABASE_URL = "postgres://#{PUBLIC_DB_USER}:#{PUBLIC_DB_PASS}@#{PUBLIC_DB_HOST}:#{PUBLIC_DB_PORT}/#{PUBLIC_DB_NAME}"

    AACT_BETA_DATABASE_URL = "postgres://#{AACT_DB_SUPER_USERNAME}@#{AACT_PUBLIC_HOSTNAME}:5432/#{AACT_BETA_DATABASE_NAME}"
    #  env vars required for capistrano:
    #  GEM_HOME
    #  GEM_PATH
    #  RUBY_VERSION
    #  LD_LIBRARY_PATH
    #  PATH

  end
end
