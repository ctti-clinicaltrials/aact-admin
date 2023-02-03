class DefinitionsController < ApplicationController
  # *******///********
  # This code uses data dictionary spreadsheet stored on the DO file server
  # *******///********
  before_action :is_admin?
  require 'csv'

  def index
    data_def_entries = DataDefinition.all
    @data_def_entries = data_def_entries.map do |data_def_entry|
      {
        "CTTI note" => data_def_entry.ctti_note,
        "column" => data_def_entry.column_name,
        "data type" => data_def_entry.data_type,
        "db schema" => data_def_entry.db_schema,
        "db section" => data_def_entry.db_section,
        "nlm doc" => data_def_entry.nlm_link,
        "row count" => data_def_entry.row_count,
        "source" => data_def_entry.source,
        "table" => data_def_entry.table_name
      }
    end
    respond_to do |format|
      format.csv  do
        response.headers['Content-Type'] = 'text/csv'
        response.headers['Content-Disposition'] = "attachment; filename=definitions.csv"
        render template: "definitions/index.csv.erb"
      end
      format.json  { render json: @data_def_entries }
      format.html { redirect_to root_path }
    end
  end

  def filtered?(params)
    searchable_attribs.each{|attrib| return true if !params[attrib].blank? }
    return false
  end

  def filters(params)
    col=[]
    searchable_attribs.each{|attrib|
      if !params[attrib].blank?
        filter = {attrib=>params[attrib]}
        col << filter
      end
    }
    col
  end

  def passes_filter?(row,params)
    filters(params).each{|filter|
      key=filter.keys.first
      val=filter.values.first
      return false if row[key].nil?
      return false if !row[key].try(:downcase).include?(val.try(:downcase))
    }
    return true
  end

  def searchable_attribs
    ['db schema', 'table', 'column', 'data type', 'xml source', 'source', 'CTTI note']
  end

end
