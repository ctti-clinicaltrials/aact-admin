class AnalyzedFreeTextTerm < ActiveRecord::Base
  def self.populate_from_file(file_name=Rails.root.join('csv','analyzed_free_text_terms.csv'))

    File.open(file_name).each_line{|line|
      line_array=line.split('|')
      old_id=line_array[0]
      term=line_array[1].strip
      if !old_id.nil? and old_id != 'FREE_TEXT_CONDITION_ID'
        new(:identifier=>old_id,
            :term=>term,
            :downcase_term=>term.downcase,
        ).save
        (2..24).each{|i|
          if line_array[i]=='Y'
            CategorizedTerm.create(
              :identifier=>old_id,
              :clinical_category=>ClinicalCategory.indexed_free_text_categories[i],
              :term_type=>'free'
            ).save!
          end
        }
      end
    }
  end

end
