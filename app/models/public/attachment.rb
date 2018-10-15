module Public
  class Attachment < Public::ProjBase
    belongs_to :project

    def renderable
      Base64.encode64(file_contents)
    end

    def remove_previously_stored_files_after_update
    end

    private

    def self.sanitize_filename(file_name)
      return File.basename(file_name)
    end

  end
end

