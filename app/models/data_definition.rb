require 'active_support/all'
class DataDefinition < ActiveRecord::Base

  def self.default_data_definitions
    Roo::Spreadsheet.open("#{Rails.public_path}/documentation/aact_data_definitions.xlsx")
  end

  def self.populate(data=self.default_data_definitions)
    self.destroy_all
    self.populate_from_file(data)
    #self.populate_row_counts
    Enumeration.populate
  end

  def self.populate_from_file(data=self.default_data_definitions)
    header = data.first
    dataOut = []
    (2..data.last_row).each do |i|
      row = Hash[[header, data.row(i)].transpose]
      if !row['table'].nil? and !row['column'].nil?
        new(:db_section=>row['db section'].try(:downcase),
            :db_schema=>row['db schema'].try(:downcase),
            :table_name=>row['table'].try(:downcase),
            :column_name=>row['column'].try(:downcase),
            :data_type=>row['data type'].try(:downcase),
            :source=>row['source'].try(:downcase),
            :ctti_note=>row['CTTI note'],
            :nlm_link=>row['nlm doc'],
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
        if row.table_name=='studies'
          row.row_count=Public::Study.count
        else
          results=Public::PublicBase.connection.execute("select count(*) from #{row.table_name}")
          row.row_count=results.getvalue(0,0) if results.ntuples == 1
        end
        row.save
      rescue
        puts ">>>>  could not get row count for #{row.table_name}"
      end
    }
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

end
