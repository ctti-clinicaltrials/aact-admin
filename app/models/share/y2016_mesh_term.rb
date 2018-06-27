class Y2016MeshTerm < ActiveRecord::Base

  def self.populate_from_file(file_name=Rails.root.join('public','csv','2016_mesh_terms.csv'))
    puts "about to populate table of mesh terms..."
    destroy_all
    File.open(file_name).each_line{|line|
      line_array=line.split('|')
      tree=line_array.first
      qualifier=tree.split('.').first
      desc=line_array[1]
      term=line.split('|').last.strip
      if !qualifier.nil?
        if where('tree_number=?',tree).empty?
          new(:qualifier=>qualifier,
              :tree_number=>tree,
              :description=>desc,
              :downcase_mesh_term=>term.downcase,
              :mesh_term=>term,
             ).save!
          end
      end
    }
  end

  def self.ids_related_to(incoming_terms=[])
    ids=[]
    incoming_terms.each {|term|
      searchable_term="%#{term.downcase}%"
      terms=MeshTerm.where('downcase_mesh_term like ?',searchable_term).pluck("mesh_term").uniq
      terms.each{|term|
        t=term.downcase
        ids << BrowseCondition.where('downcase_mesh_term = ?',t).pluck(:nct_id).uniq
        ids << BrowseIntervention.where('downcase_mesh_term = ?',t).pluck(:nct_id).uniq
      }
    }
    ids.flatten.uniq
  end

end
