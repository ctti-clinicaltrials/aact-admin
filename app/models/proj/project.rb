module Proj
  class Project < ActiveRecord::Base
    has_many :attachments,  :dependent => :destroy
    has_many :datasets,     :dependent => :destroy
    has_many :faqs,         :dependent => :destroy
    has_many :publications, :dependent => :destroy

    def image
      attachments.select{|a| a.is_image }.first
    end

    def self.schema_name_array
      all.map{|p| p.schema_name }
    end

    def self.schema_name_list
      all.map{|p| p.schema_name }.join(', ')
    end

    def publication_url
      pub = publications.first if !publications.empty?
      pub.url if pub
    end

  end
end

