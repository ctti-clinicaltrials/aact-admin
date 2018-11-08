module Proj
  class Project < ActiveRecord::Base
    has_many :attachments,  :dependent => :destroy
    has_many :datasets,     :dependent => :destroy
    has_many :publications, :dependent => :destroy

    def image
      attachments.select{|a| a.is_image }.first
    end

  end
end

