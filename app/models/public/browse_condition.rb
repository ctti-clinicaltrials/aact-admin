module Public
  class BrowseCondition < Public::PublicBase
    #  Note:  Read-only All public data is managed by other apps (aact & aact-proj).
    after_initialize :readonly!
    belongs_to :study

    scope :with_terms,   lambda { |terms| where(:downcase_mesh_term => terms) }

    def self.ids_for_terms(terms)
      with_terms(terms).pluck(:nct_id).uniq
    end

  end
end

