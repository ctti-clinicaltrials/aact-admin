class DefinitionsController < ApplicationController
  # *******///********
  # This code uses data dictionary spreadsheet stored on the DO file server
  # *******///********
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
        "enumerations" => data_def_entry.enumerations,
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

  def fix_attribs(hash)
    enums=Enumeration.new.enums
    enum_tabs=enums.map {|row| row[0]}
    enum_cols=enums.map {|row| row[1]}
    tab=hash['table'].downcase
    col=hash['column'].downcase

    if hash['source']
      fixed_content=hash['source'].gsub(/\u003c/, "&lt;").gsub(/>/, "&gt;")
      hash['source']=fixed_content
    end

    if enum_tabs.include? tab and enum_cols.include? col
      dd=DataDefinition.where('table_name=? and column_name=?',tab,col).first
      if dd and !dd.enumerations.nil?
        str="<select>"
        dd.enumerations.each{|e|
          cnt=e.last.first
          pct=e.last.last
          str=str+"<option>"+cnt+" ("+pct+")&nbsp&nbsp; - "+e.first+"</option>"
        }
        str=str+'</select>'
        hash['enumerations'] = str.html_safe
      end
    end

    if hash['nlm doc'].present?
      url=hash["db section"].downcase == "results" ? @@results_url : @@protocol_url
      hash['nlm doc'] = "<a href=#{url}##{hash['nlm doc']} class='navItem' target='_blank'><i class='fa fa-book'></i></a>".html_safe
    end

    if (col == 'id') or (tab.downcase == 'studies' and col == 'nct_id')
      # If this is the table's primary key, display row count.
      results=ActiveRecord::Base.connection.execute("SELECT row_count FROM data_definitions WHERE table_name='#{tab}' and column_name='#{col}'")
      if results.ntuples > 0
        row_count=results.getvalue(0,0).to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
        hash['row count']=row_count
      else
        hash['row count']=0
      end
      hash['table'] = "<span class='primary-key' id='#{tab}'>#{hash['table']}</span>"
    end

    return hash
  end

  def searchable_attribs
    ['db schema', 'table', 'column', 'data type', 'xml source', 'source', 'CTTI note']
  end

end
