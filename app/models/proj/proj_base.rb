module Proj
  class ProjBase < ActiveRecord::Base
    establish_connection(ENV["AACT_PROJ_DATABASE_URL"])
    self.abstract_class = true
  end
end
