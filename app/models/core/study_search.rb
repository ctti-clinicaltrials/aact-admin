module Core
    class StudySearch< Core::Base
        validates  :query, :grouping, :name, presence: true
    end  
  end