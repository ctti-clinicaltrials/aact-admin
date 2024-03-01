class DefinitionsController < ApplicationController
  require 'csv'

  def index
    data_def_entries = DataDefinition.all
    @data_def_entries = data_def_entries.map do |data_def_entry|
      hash = {
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

      if conditions_met_for_select?(data_def_entry)
        hash["enumerations"] = generate_select_snippet(data_def_entry)
      end
      fix_attribs(hash)

      results_url = Util::FilePresentationManager.new.nlm_results_data_url
      protocol_url = Util::FilePresentationManager.new.nlm_protocol_data_url

      if hash['nlm doc'].present?
        url = hash["db section"].downcase == "results" ? results_url : protocol_url
        hash['nlm doc'] = "<a href=#{url}##{hash['nlm doc']} class='navItem' target='_blank'><i class='fa fa-book'></i></a>".html_safe
      end

      hash
    end

    respond_to do |format|
      format.csv do
        response.headers['Content-Type'] = 'text/csv'
        response.headers['Content-Disposition'] = "attachment; filename=definitions.csv"
        render template: "definitions/index.csv.erb"
      end
      format.json { render json: @data_def_entries }
      format.html { redirect_to root_path }
    end
  end

  def filtered?(params)
    searchable_attribs.each { |attrib| return true if !params[attrib].blank? }
    return false
  end

  def filters(params)
    col = []
    searchable_attribs.each do |attrib|
      if !params[attrib].blank?
        filter = { attrib => params[attrib] }
        col << filter
      end
    end
    col
  end

  def passes_filter?(row, params)
    filters(params).each do |filter|
      key = filter.keys.first
      val = filter.values.first
      return false if row[key].nil?
      return false if !row[key].try(:downcase).include?(val.try(:downcase))
    end
    return true
  end

  def conditions_met_for_select?(data_def_entry)
    true
  end

  def generate_select_snippet(data_def_entry)
    if data_def_entry['enumerations'].present?
      options_hash = JSON.parse(data_def_entry['enumerations'])
  
      options = options_hash.map do |key, value|
        "<option value='#{key}'>#{key} (#{value[0]} - #{value[1]})</option>"
      end
      select_tag = "<select style='width: -webkit-fill-available;'>#{options.join}</select>".html_safe
    else
      select_tag = ""
    end
  
    select_tag
  rescue JSON::ParserError
    select_tag = "Invalid JSON"
  end

  def fix_attribs(hash)
    hash
  end

  def searchable_attribs
    ['db schema', 'table', 'column', 'data type', 'xml source', 'source', 'CTTI note']
  end
end
