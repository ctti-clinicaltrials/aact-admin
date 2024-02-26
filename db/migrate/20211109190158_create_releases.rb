class CreateReleases < ActiveRecord::Migration[4.2]
  def change
    create_table :releases do |t|
      t.string :title
      t.string :subtitle
      t.date :released_on
      t.text :body

      t.timestamps
    end
  end
end
