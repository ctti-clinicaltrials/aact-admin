module Share
  class Dataset < ActiveRecord::Base
    belongs_to :project

  end
end

