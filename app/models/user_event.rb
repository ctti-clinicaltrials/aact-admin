class UserEvent < ActiveRecord::Base

  def add_problem(problem)
    if self.description.blank?
      self.description = problem
    else
      self.description = "#{self.description} \n#{problem}"
    end
    self.event_type = "#{self.event_type} problem"  if self.event_type && !self.event_type.include?('problem')
  end

end
