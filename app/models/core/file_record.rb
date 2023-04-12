module Core
  class FileRecord < Core::Base

    TYPE_MAP={
      "snapshot"    => "static_db_copies",
      "pipefiles"   => "exported_files",
      "covid-19"    => "covid-19",
      }
      
    def self.daily(file_type)
      where(created_at: (Date.today.beginning_of_month..DateTime.current), file_type: file_type).order(created_at: :desc)
    end

    def self.monthly(file_type)
      where("created_at < :end_date", end_date: Date.today.beginning_of_month).where(file_type: file_type).order(created_at: :desc)
    end

    def self.everything(file_type)
      where(file_type: file_type).order(created_at: :desc)
    end
    
    def active_url
      "/static/#{TYPE_MAP[file_type]}/daily/#{created_at.strftime('%Y-%m-%d')}"
    end

    def json
      {
        id: id,
        file_size: file_size,
        file_type: file_type,
        created_at: created_at,
        url: active_url
      }
    end
  end
end


# TEST
