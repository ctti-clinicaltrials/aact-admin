class SavedQuery < ActiveRecord::Base
  belongs_to :user
  validates :title, :description, :sql, presence: true
end
