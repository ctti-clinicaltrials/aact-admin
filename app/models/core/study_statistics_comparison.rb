module Core
  class StudyStatisticsComparison < Core::Base
    validates :ctgov_selector, :table, :column, :condition, :instances_query, :unique_query, presence: true
  end  
end
