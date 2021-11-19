class CreateReleases < ActiveRecord::Migration[5.2]
  def change
    create_table :releases do |t|
      t.string :title
      t.string :subtitle
      t.datetime :created_at
      t.text :body

      t.timestamps
    end
  end
end
