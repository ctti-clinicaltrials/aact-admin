class CreateTableSavedQuery < ActiveRecord::Migration
  def change
    create_table :table_saved_queries do |t|
      t.string :title
      t.string :description
      t.string :sql
      t.boolean :public
      t.references :user, null: false        
      t.timestamps
    end
  end
end
