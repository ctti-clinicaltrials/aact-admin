class CreateCoreStudySearches < ActiveRecord::Migration
  def change
    create_table :core_study_searches do |t|

      t.timestamps null: false
    end
  end
end
