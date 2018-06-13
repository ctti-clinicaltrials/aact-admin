class AnalyzedMeshTerm < ActiveRecord::Base
  def self.populate_from_file(file_name=Rails.root.join('csv','analyzed_mesh_terms.csv'))
    puts "about to populate table of analyzed mesh terms..."
    File.open(file_name).each_line{|line|
      line_array=line.split('|')
      tree=line_array.first
      qualifier=tree.split('.').first
      desc=''
      term=line_array[1].strip
      if !qualifier.nil? and qualifier != 'MESH_ID'
        new(:qualifier=>qualifier,
            :identifier=>tree,
            :description=>desc,
            :downcase_term=>term.downcase,
            :term=>term,
        ).save
        (3..16).each{|i|
          if line_array[i]=='Y'
            CategorizedTerm.create(
              :identifier=>tree,
              :clinical_category=>ClinicalCategory.indexed_categories[i],
              :term_type=>'mesh'
            ).save!
          end
        }
      end
    }
  end

end
