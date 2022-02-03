class Release < ActiveRecord::Base
  validates :title, :subtitle, :released_on, :body, presence: true
end
