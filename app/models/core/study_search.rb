module Core
    class StudySearch< Core::Base
        #validates :save_tsv, :query, :grouping, :name, :active, presence: true   original 
       # validates :save_tsv, :query, :grouping, :name, :beta_api, presence: true
        validates  :query, :grouping, :name, presence: true
    end  
  end