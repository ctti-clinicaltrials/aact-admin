class Tag
  include ActiveModel::Model

  attr_accessor :label

  def self.all
    Public::TaggedTerm.pluck(:tag).uniq.collect{ |t| Tag.new({:label => t}) }
  end

  def terms
    Public::TaggedTerm.where('tag = ?', label).order(:term)
  end
end
