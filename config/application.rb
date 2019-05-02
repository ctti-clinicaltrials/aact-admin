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
    config.active_record.raise_in_transactional_callbacks = true

    AACT_DB_SUPER_USERNAME = ENV['AACT_DB_SUPER_USERNAME'] || 'ctti'
    AACT_PUBLIC_HOSTNAME = ENV['AACT_PUBLIC_HOSTNAME'] || 'localhost'
    if Rails.env == 'test'
      APPLICATION_HOST          = 'localhost'
      AACT_PUBLIC_HOSTNAME      = 'localhost'
      AACT_BACK_DATABASE_NAME   = 'aact_back_test'
      AACT_ADMIN_DATABASE_NAME  = 'aact_admin_test'
      AACT_PUBLIC_DATABASE_NAME = 'aact_test'
      AACT_PUBLIC_IP_ADDRESS    = '127.0.0.1'
    else
      APPLICATION_HOST          = ENV['APPLICATION_HOST'] || 'localhost'
      AACT_PUBLIC_HOSTNAME      = ENV['AACT_PUBLIC_HOSTNAME'] || 'localhost'
      AACT_BACK_DATABASE_NAME   = ENV['AACT_BACK_DATABASE_NAME'] || 'aact_back'
      AACT_ADMIN_DATABASE_NAME  = ENV['AACT_ADMIN_DATABASE_NAME'] || 'aact_admin'
      AACT_PUBLIC_DATABASE_NAME = ENV['AACT_PUBLIC_DATABASE_NAME'] || 'aact'
      AACT_PUBLIC_IP_ADDRESS    = ENV['AACT_PUBLIC_IP_ADDRESS'] || '127.0.0.1'
    end
    AACT_BACK_DATABASE_URL   = "postgres://#{AACT_DB_SUPER_USERNAME}@#{APPLICATION_HOST}:5432/#{AACT_BACK_DATABASE_NAME}"
    AACT_ADMIN_DATABASE_URL  = "postgres://#{AACT_DB_SUPER_USERNAME}@#{APPLICATION_HOST}:5432/#{AACT_ADMIN_DATABASE_NAME}"
    AACT_PUBLIC_DATABASE_URL = "postgres://#{AACT_DB_SUPER_USERNAME}@#{AACT_PUBLIC_HOSTNAME}:5432/#{AACT_PUBLIC_DATABASE_NAME}"

  end
end
