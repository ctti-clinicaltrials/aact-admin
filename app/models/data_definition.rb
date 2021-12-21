require 'active_support/all'
class DataDefinition < ActiveRecord::Base

  def self.default_data_definitions
    Roo::Spreadsheet.open("#{Rails.public_path}/documentation/aact_data_definitions.xlsx")
  end

  def self.populate(data=self.default_data_definitions)
    self.destroy_all
    self.populate_from_file(data)
    self.populate_row_counts
    Enumeration.populate
  end

  def self.populate_from_file(data=self.default_data_definitions)
    header = data.first
    dataOut = []
    (2..data.last_row).each do |i|
      row = Hash[[header, data.row(i)].transpose]
      if !row['table'].nil? and !row['column'].nil?
        new(:db_section   => row['db section'].try(:downcase),
            :db_schema    => row['db schema'].try(:downcase),
            :table_name   => row['table'].try(:downcase),
            :column_name  => row['column'].try(:downcase),
            :data_type    => row['data type'].try(:downcase),
            :source       => row['source'].try(:downcase),
            :ctti_note    => row['CTTI note'],
            :nlm_link     => row['nlm doc'],
           ).save!
      end
    end
  end

  def self.populate_row_counts
    # save count for each table where the primary key is id
    rows=where("column_name='id'")
    populate_from_file if rows.size==0
    rows.each{|row|
      begin
        results=Public::PublicBase.connection.execute("select count(*) from #{row.table_name}")
        row.row_count=results.getvalue(0,0) if results.ntuples == 1
        row.save
      rescue
        puts ">>>>  could not get row count for #{row.table_name}"
      end
    }
    # Study table is only one where primary key is NCT_ID, not ID. Determine/save row count separately
    study_row=where("lower(table_name) = 'studies' and lower(column_name)='nct_id'").first
    study_row.row_count=Public::Study.count
    study_row.save!
  end

  def self.single_study_tables
    [
      'brief_summaries',
      'designs',
      'detailed_descriptions',
      'eligibilities',
      'participant_flows',
      'calculated_values',
      'studies'
    ]
  end

  def self.make_json_file(schema='ctgov')
    if schema == "archive"
      file_name="aact_archive_data_definitions"
    elsif schema == "beta"
      file_name="aact_beta_data_definitions"
    else
      file_name="aact_data_definitions"
    end
    data = Roo::Spreadsheet.open("#{Rails.configuration.aact[:static_files_directory]}/documentation/#{file_name}.xlsx")

    unless File.exists?("public/#{file_name}.json")
      header = data.first
      dataOut = []
      (2..data.last_row).each do |i|
        row = Hash[[header, data.row(i)].transpose]
        if !row['table'].nil? and !row['column'].nil?
            dataOut << fix_attribs(row)
        end
      end
      File.open("public/#{file_name}.json","w") do |f|
        f.write(dataOut.to_json)
      end
    end

    return JSON.parse(File.read("public/#{file_name}.json"))

  end

  def self.fix_attribs(hash)
    results_url=Util::FilePresentationManager.new.nlm_results_data_url
    protocol_url=Util::FilePresentationManager.new.nlm_protocol_data_url

    enums=Enumeration.new.enums
    enum_tabs=enums.map {|row| row[0]}
    enum_cols=enums.map {|row| row[1]}
    tab=Rails::Html::FullSanitizer.new.sanitize(hash["table"]).downcase
    col=hash['column'].downcase

    if hash['source']
      fixed_content=hash['source'].gsub(/\u003c/, "&lt;").gsub(/>/, "&gt;")
      hash['source']=fixed_content
    end

    if enum_tabs.include? tab and enum_cols.include? col
      dd=DataDefinition.where('table_name=? and column_name=?',tab,col).first
      if dd and !dd.enumerations.nil?
        str="<select>"
        dd.enumerations.first(3).each{|e|
          cnt=e.last.first
          pct=e.last.last
          str=str+"<option>"+cnt+" ("+pct+")&nbsp&nbsp; - "+e.first+"</option>"
        }
        str=str+'</select>'
        hash['enumerations']=str.html_safe
      end
    end

    if hash['nlm doc'].present?
      url=hash["db section"].downcase == "results" ? results_url : protocol_url
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


end
