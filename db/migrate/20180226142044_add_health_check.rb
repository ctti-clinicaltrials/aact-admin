class AddHealthCheck < ActiveRecord::Migration[4.2]
  def change

    create_table "ctgov.enumerations" do |t|
      t.string  :table_name
      t.string  :column_name
      t.string  :column_value
      t.integer :value_count
      t.decimal :value_percent
      t.string  :description
      t.timestamps null: false
    end

    create_table "ctgov.health_checks" do |t|
      t.text    :query
      t.string  :cost
      t.float   :actual_time,  :precision => 4, :scale => 2
      t.integer :row_count
      t.string :description
      t.timestamps null: false
    end

  end
end
