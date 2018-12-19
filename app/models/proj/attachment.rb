module Proj
  class Attachment  < ActiveRecord::Base
    belongs_to :project

    def renderable
      Base64.encode64(file_contents)
    end

  end
end

