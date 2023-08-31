Rails.application.configure do
  host = ENV["APPLICATION_HOST"] || 'localhost'
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.serve_static_files = ENV['RAILS_SERVE_STATIC_FILES'].present?
  config.middleware.use Rack::Deflater
  # config.assets.js_compressor = :uglifier
  config.assets.digest = true
  config.log_level = :debug
  config.assets.precompile =  ['*.js', '*.css', '*.scss']
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings =  {
    address: 'email-smtp.us-east-1.amazonaws.com',
    port: 587,
    domain: ENV['APPLICATION_HOST'],
    user_name: ENV['SMTP_USER'],
    password: ENV['SMTP_PASS'],
    authentication: :login,
    enable_starttls_auto: true
  }
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.log_formatter = ::Logger::Formatter.new
  config.active_record.dump_schema_after_migration = false
  config.action_mailer.default_url_options = { host: host }

  config.aact = {static_files_directory: "/aact-files"}
end

