class Release < ActiveRecord::Base
  validates :title, presence: true
  validates :subtitle, presence: true
  validates :released_on, presence: true
  validates :body, presence: true
end
