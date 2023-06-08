module Core
  class StudyStatisticsComparison < Core::Base
    validates :ctgov_selector, :table, :column, :condition, presence: true
  end  
end
