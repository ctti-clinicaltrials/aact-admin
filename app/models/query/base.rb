module Query
  class Base < ActiveRecord::Base
    self.abstract_class = true
    establish_connection(AACT::Application::AACT_QUERY_DATABASE_URL)
  end
end
