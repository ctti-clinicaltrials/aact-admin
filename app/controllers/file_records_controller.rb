class FileRecordsController < ApplicationController

  TYPE_MAP={
    "static_db_copies"  => "snapshot",
    "exported_files"    => "pipefiles",
    "covid-19"          => "covid-19",
    }

  def index 
    records = Core::FileRecord.all
    records = records.where(file_type: params[:type]) if params[:type]
    records = records.where('created_at >= ?', params[:from]) if params[:from]
    records = records.where('created_at <= ?', params[:to]) if params[:to]
    render json:records.map(&:json)
  end

  def active_url
    @type=params[:type]
    @time=params[:time]
    @filename=params[:filename]

    date = Date.parse(@filename)
    file_record = Core::FileRecord.where(file_type: TYPE_MAP[@type]).where(created_at: (date..date+1)).order(created_at: :desc).first
    redirect_to file_record.url
  end
end
