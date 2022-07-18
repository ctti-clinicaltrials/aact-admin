module Core
  class FileRecord < Core::Base
    def self.daily(file_type)
      where(created_at: (Date.today.beginning_of_month..DateTime.current), file_type: file_type).order(created_at: :desc)
    end

    def self.monthly(file_type)
      where("created_at < :end_date", end_date: Date.today.beginning_of_month).where(file_type: file_type).order(created_at: :desc)
    end

    def self.everything(file_type)
      where(file_type: file_type).order(created_at: :desc)
    end
  end
end
