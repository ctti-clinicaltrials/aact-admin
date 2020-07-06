#Rack::Timeout.service_timeout = 20  # seconds
#Rails.application.config.middleware.insert_before Rack::Sendfile, ActionDispatch::DebugLocks
Rails.application.config.middleware.insert_before Rack::Runtime, Rack::Timeout, service_timeout:20 
#Rack::Timeout.timeout = 20
Rack::Timeout::StateChangeLoggingObserver::STATE_LOG_LEVEL[:ready] = :debug
Rack::Timeout::StateChangeLoggingObserver::STATE_LOG_LEVEL[:completed] = :debug
