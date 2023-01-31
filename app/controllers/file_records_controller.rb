class FileRecordsController < ApplicationController

  TYPE_MAP={
    "static_db_copies"  => "snapshot",
    "exported_files"    => "pipefiles",
    "covid-19"          => "covid-19",
    }

  def active_url
    @type=params[:type]
    @time=params[:time]
    @filename=params[:filename]

    date = Date.parse(@filename)
    file_record = Core::FileRecord.where(file_type: TYPE_MAP[@type]).where(created_at: (date..date+1)).order(created_at: :desc).first
      if file_record.exist?
        file_downloads =  Core::FileDownloads.where(file_record_id: file_record.id)
        file_downloads.file_record_id = file_record.id
        file_downloads.count += 1
      end
    redirect_to file_record.url
  end
end


After that add code in the action file_records active_url that adds an 
entry every time the action gets called, the FileDownload is associated with 
the FileRecord that we found. There is no entry created if the FileRecord is not found.
