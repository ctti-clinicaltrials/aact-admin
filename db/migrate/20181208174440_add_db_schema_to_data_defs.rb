class AddDbSchemaToDataDefs < ActiveRecord::Migration[4.2]

  def up
    add_column 'data_definitions', :db_schema, :string
  end

  def down
    remove_column 'data_definitions', :db_schema
  end

end
