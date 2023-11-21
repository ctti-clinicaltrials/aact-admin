class RemoveSearchResults < ActiveRecord::Migration[5.0] # or your Rails version
  def up
    execute <<-SQL
      DROP VIEW IF EXISTS covid_19_studies CASCADE;
      DROP VIEW IF EXISTS categories CASCADE;
    SQL

    drop_table :search_results
  end
end
