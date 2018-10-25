module Public
  class Dataset < Public::ProjBase
    #  Note:  Read-only All public data is managed by other apps (aact & aact-proj).
    after_initialize :readonly!
    belongs_to :project

  end
end

