module Public
  class TaggedTerm < Public::ProjBase
    #  Note:  Read-only All public data is managed by other apps (aact & aact-proj).
    after_initialize :readonly!

    def self.terms_for_tag(tt)
      #where('tag = ?',tag).pluck(:term).uniq
      where('tag = ?', tt.tag)
    end

    def terms
      Public::TaggedTerm.where('tag = ?', tag).order(:term)
    end

    def tags
      Public::TaggedTerm.where('term = ?', term).order(:tag)
    end

  end
end
