module Public
  class BrowseIntervention < Public::ProjBase
    belongs_to :study

    scope :with_terms,   lambda { |terms| where(:downcase_mesh_term => terms) }

    def self.ids_for_terms(terms)
      with_terms(terms).pluck(:nct_id).uniq
    end

  end
end

