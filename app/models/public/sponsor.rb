module Public
  class Sponsor < Public::PublicBase
    #  Note:  Read-only All public data is managed by other apps (aact & aact-proj).
    after_initialize :readonly!

    belongs_to :study

  end
end

