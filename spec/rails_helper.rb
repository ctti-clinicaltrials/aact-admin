require 'helpers/form_helpers.rb'
ENV["RACK_ENV"] = "test"
ENV["RAILS_ENV"] = "test"

require File.expand_path("../../config/environment", __FILE__)
abort("AACT_ADMIN_DATABASE_URL global variable is not set")   if !AACT::Application::AACT_ADMIN_DATABASE_URL
abort("AACT_BACK_DATABASE_URL global variable is not set")    if !AACT::Application::AACT_BACK_DATABASE_URL
abort("AACT_PUBLIC_DATABASE_URL global variable is not set")  if !AACT::Application::AACT_PUBLIC_DATABASE_URL
abort("AACT_PUBLIC_HOSTNAME environment variable is not set")      if !AACT::Application::AACT_PUBLIC_HOSTNAME
abort("AACT_PUBLIC_DATABASE_NAME global variable is not set") if !AACT::Application::AACT_PUBLIC_DATABASE_NAME
abort("AACT_DB_SUPER_USERNAME global variable is not set")    if !AACT::Application::AACT_DB_SUPER_USERNAME

require "rspec/rails"

Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |file| require file }

module Features
  # Extend this module in spec/support/features/*.rb
  include Formulaic::Dsl
end

RSpec.configure do |config|
  config.include Features, type: :feature
  config.infer_base_class_for_anonymous_controllers = false
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = true

  config.include FormHelpers, :type => :feature
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view
  # Added these 2 lines so that we can use the sign_in method in request specs
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :system

  config.before(:each) do |example|
    # ensure app user logged into db connections
    Public::PublicBase.establish_connection(
      adapter: 'postgresql',
      encoding: 'utf8',
      hostname: AACT::Application::AACT_PUBLIC_HOSTNAME,
      database: AACT::Application::AACT_PUBLIC_DATABASE_NAME,
      username: AACT::Application::AACT_DB_SUPER_USERNAME)
    @dbconfig = YAML.load(File.read('config/database.yml'))
    ActiveRecord::Base.establish_connection @dbconfig[:test]
  end
end

ActiveRecord::Migration.maintain_test_schema!
