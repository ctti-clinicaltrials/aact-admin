class CreateSavedQueries < ActiveRecord::Migration
  def change
    create_table :saved_queries do |t|
      t.string :title
      t.string :description
      t.string :sql
      t.boolean :public
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
