class FileRecordsController < ApplicationController
  TYPE_MAP = {
    "static_db_copies" => "snapshot",
    "exported_files"   => "pipefiles",
    "covid-19"         => "covid-19",
  }

  def index
    records = Core::FileRecord.all
    records = records.where(file_type: params[:type]) if params[:type]
    records = records.where('created_at >= ?', params[:from]) if params[:from]
    records = records.where('created_at <= ?', params[:to]) if params[:to]
    render json: records.map(&:json)
  end

  def active_url
    @type = params[:type]
    @time = params[:time]
    @filename = params[:filename]

    date = Date.parse(@filename)
    file_record = Core::FileRecord.where(file_type: TYPE_MAP[@type])
                                  .where(created_at: (date..date + 1))
                                  .order(created_at: :desc)
                                  .first

    if file_record
      file_downloads = FileDownload.create(file_record_id: file_record.id)
      redirect_to file_record.url
    else
      render_not_found(file_record.nil?)
    end
  end

  private

  def render_not_found(condition)
    respond_to do |format|
      format.html { render 'errors/not_found', status: condition ? :not_found : :ok }
      format.json { render json: { error: 'Not Found' }, status: condition ? :not_found : :ok }
    end
  end
end
