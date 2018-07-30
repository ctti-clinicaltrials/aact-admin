class String
  def is_missing_the_day?
    # use this method on string representations of dates.  If only one space in the string, then the day is not provided.
    (count ' ') == 1
  end
end

module Public
  class Study < Public::PublicBase

    attr_accessor :xml, :with_related_records, :with_related_organizations

    def as_indexed_json(options = {})
      self.as_json({
        only: [:nct_id, :acronym, :brief_title, :overall_status, :phase, :start_date, :primary_completion_date],
        include: {
          browse_conditions: { only: :mesh_term },
          browse_interventions: { only: :mesh_term },
          keywords: { only: :name },
          sponsors: { only: :name },
        }
      })
    end

    def self.current_interventional
      self.interventional and self.current
    end

    scope :started_between, lambda {|sdate, edate| where("start_date >= ? AND created_at <= ?", sdate, edate )}
    scope :changed_since,   lambda {|cdate| where("last_changed_date >= ?", cdate )}
    scope :completed_since, lambda {|cdate| where("completion_date >= ?", cdate )}
    scope :sponsored_by,    lambda {|agency| joins(:sponsors).where("sponsors.agency LIKE ?", "#{agency}%")}
    scope :with_one_to_ones,   -> { joins(:eligibility, :brief_summary, :design, :detailed_description) }
    scope :with_organizations, -> { joins(:sponsors, :facilities, :central_contacts, :responsible_parties) }
    self.primary_key = 'nct_id'

    has_one  :brief_summary,         :foreign_key => 'nct_id', :dependent => :delete
    has_one  :design,                :foreign_key => 'nct_id', :dependent => :delete
    has_one  :detailed_description,  :foreign_key => 'nct_id', :dependent => :delete
    has_one  :eligibility,           :foreign_key => 'nct_id', :dependent => :delete
    has_one  :participant_flow,      :foreign_key => 'nct_id', :dependent => :delete
    has_one  :calculated_value,      :foreign_key => 'nct_id', :dependent => :delete

    has_many :baseline_measurements, :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :baseline_counts,       :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :browse_conditions,     :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :browse_interventions,  :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :central_contacts,      :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :conditions,            :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :countries,             :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :design_outcomes,       :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :design_groups,         :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :design_group_interventions, :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :documents,             :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :drop_withdrawals,      :foreign_key => 'nct_id', :dependent => :delete_all

    has_many :facilities,            :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :facility_contacts,     :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :facility_investigators,:foreign_key => 'nct_id', :dependent => :delete_all
    has_many :id_information,        :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :interventions,         :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :intervention_other_names, :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :keywords,              :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :links,                 :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :milestones,            :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :outcomes,              :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :outcome_analysis_groups, :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :outcome_analyses,      :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :outcome_measurements,  :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :overall_officials,     :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :pending_results,       :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :references,            :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :reported_events,       :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :responsible_parties,   :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :result_agreements,     :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :result_contacts,       :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :result_groups,         :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :sponsors,              :foreign_key => 'nct_id', :dependent => :delete_all
    accepts_nested_attributes_for :outcomes

    def initialize(hash)
      super
      @xml=hash[:xml]
      self.nct_id=hash[:nct_id]
    end

    def opts
      {
        :xml=>xml,
        :nct_id=>nct_id
      }
    end

    def self.all_nctids
      all.collect{|s|s.nct_id}
    end

    def summary
      brief_summary.description
    end

    def sampling_method
      eligibility.sampling_method
    end

    def study_population
      eligibility.study_population
    end

    def study_references
      references.select{|r|r.type!='results_reference'}
    end

    def result_references
      references.select{|r|r.type=='results_reference'}
    end

    def healthy_volunteers?
      eligibility.healthy_volunteers
    end

    def minimum_age
      eligibility.minimum_age
    end

    def maximum_age
      eligibility.maximum_age
    end

    def age_range
      "#{minimum_age} - #{maximum_age}"
    end

    def lead_sponsors
      sponsors.where(lead_or_collaborator: 'lead')
    end

    def collaborators
      sponsors.where(lead_or_collaborator: 'collaborator')
    end

    def lead_sponsor_names
      lead_sponsors.select{|s|s.name}
    end

    def number_of_sites
      facilities.size
    end

    def pi
      val=''
      responsible_parties.each{|r|val=r.investigator_full_name if r.responsible_party_type=='Principal Investigator'}
      val
    end

    def status
      overall_status
    end

    def name
      brief_title
    end

    def outcome_analyses
      OutcomeAnalysis.where('nct_id=?',nct_id)
    end

    def outcome_measurements
      OutcomeMeasurement.where('nct_id=?',nct_id)
    end

    def outcome_counts
      OutcomeCount.where('nct_id=?',nct_id)
    end

    def intervention_names
      interventions.collect{|x|x.name}.join(', ')
    end

    def condition_names
      conditions.collect{|x|x.name}.join(', ')
    end

    def self.with_organization(user_provided_org)
      org=make_queriable(user_provided_org)
      ids=(ResponsibleParty.where('organization like ?',"%#{org}%").pluck(:nct_id) \
        + OverallOfficial.where('affiliation like ?',"%#{org}%").pluck(:nct_id) \
        + Facility.where('name like ?',"%#{org}%").pluck(:nct_id) \
        + where('source like ?',"%#{org}%").pluck(:nct_id)).flatten.uniq
      where(nct_id: ids).includes(:sponsors).includes(:facilities).includes(:brief_summary).includes(:detailed_description).includes(:design).includes(:eligibility).includes(:overall_officials).includes(:responsible_parties)
    end

  end
end
