class AddFaqsTable < ActiveRecord::Migration

  def change

    create_table "ctgov.faqs" do |t|
      t.integer  "project_id"
      t.string   "name"
      t.string   "url"
      t.string   "citation"
      t.text     "description"
      t.timestamps null: false
    end

  end

end
