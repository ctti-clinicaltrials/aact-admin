class AddDbSchemaToDataDefs < ActiveRecord::Migration

  def up
    add_column 'data_definitions', :db_schema, :string
  end

  def down
    remove_column 'data_definitions', :db_schema
  end

end
