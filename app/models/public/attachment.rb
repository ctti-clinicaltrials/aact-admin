module Public
  class Attachment < Public::ProjBase
    #  Note:  Read-only All public data is managed by other apps (aact & aact-proj).
    after_initialize :readonly!
    belongs_to :project

    def renderable
      Base64.encode64(file_contents)
    end

  end
end

