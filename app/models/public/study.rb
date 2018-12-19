class String
  def is_missing_the_day?
    # use this method on string representations of dates.  If only one space in the string, then the day is not provided.
    (count ' ') == 1
  end
end

module Public
  class Study < Public::PublicBase
    #  Note:  Read-only All public data is managed by other apps (aact & aact-proj).
    after_initialize :readonly!

    scope :started_between,   lambda {|sdate, edate| where("start_date >= ? AND created_at <= ?", sdate, edate )}
    scope :started_since,     lambda {|cdate| where("start_date >= ?", cdate )}
    scope :completed_since,   lambda {|cdate| where("primary_completion_date >= ?", cdate )}
    scope :with_condition,    lambda {|term| joins(:browse_conditions).where("browse_conditions.downcase_mesh_term = ?", "#{term.downcase}")}
    scope :with_intervention, lambda {|term| joins(:browse_interventions).where("browse_interventions.downcase_mesh_term = ?", "#{term.downcase}")}

    has_many :browse_conditions,:foreign_key => 'nct_id'
    has_many :browse_interventions,:foreign_key => 'nct_id'

    self.primary_key = 'nct_id'

    def self.ids_tagged(tag)
      terms=Public::TaggedTerm.terms_for_tag(tag).pluck(:term).uniq
      ids=Public::BrowseCondition.ids_for_terms(terms) + Public::BrowseIntervention.ids_for_terms(terms)
      return ids
    end

    def self.tagged(tag)
      where(:nct_id => ids_tagged(tag)).uniq
    end

    def self.all_nctids
      all.collect{|s|s.nct_id}
    end

    def status
      overall_status
    end

    def name
      brief_title
    end

  end
end
