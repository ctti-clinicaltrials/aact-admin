module Core
  class Base < ActiveRecord::Base
    self.abstract_class = true
    establish_connection(AACT::Application::AACT_CORE_DATABASE_URL)
  end
end
