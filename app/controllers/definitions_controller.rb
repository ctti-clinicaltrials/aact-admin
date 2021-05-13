class DefinitionsController < ApplicationController

  # *******///********
  # This code uses data dictionary spreadsheet stored on the DO file server
  # *******///********

  def index
    unless File.exists?('public/aact_data_definitions.json')
      DataDefinition.make_json_file
    end
    json_file = JSON.parse(File.read('public/aact_data_definitions.json'))
    dataOut = []
    json_file.each do |row|
      if !row['table'].nil? and !row['column'].nil?
        if !filtered?(params) or passes_filter?(row,params)
          dataOut << row
        end
      end
    end
  
    render json: dataOut, root: false
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
