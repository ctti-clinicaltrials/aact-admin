module Public
  class Project < Public::ProjBase
    #  Note:  Read-only All public data is managed by other apps (aact & aact-proj).
    after_initialize :readonly!

    has_many :attachments,  :dependent => :destroy
    has_many :datasets,     :dependent => :destroy
    has_many :publications, :dependent => :destroy

    def image
      attachments.select{|a| a.is_image }.first
    end

  end
end

