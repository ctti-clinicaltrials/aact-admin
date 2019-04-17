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

    def self.schema_diagram_file_names
      root_dir=Util::FilePresentationManager.new.root_dir
      Proj::Project.schema_name_array.map{ |schema_name|
        fn = "#{root_dir}#{schema_name}_schema.png"
        fn if File.exist?(fn)
      }
    end

    def publication_url
      pub = publications.first if !publications.empty?
      pub.url if pub
    end

    def display_start_date
      start_date.strftime("%B %d, %Y")
    end

    def schema_diagram_file_name
      root_dir=Util::FilePresentationManager.new.root_dir
      fn = "#{root_dir}#{schema_name}_schema.png"
    end

  end
end

