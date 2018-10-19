module Public
  class TaggedTerm < Public::ProjBase

    def self.terms_for_tag(tag)
      where('tag = ?',tag).pluck(:term).uniq
    end

  end
end
