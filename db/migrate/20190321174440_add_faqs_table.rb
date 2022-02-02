class AddFaqsTable < ActiveRecord::Migration

  def change

    create_table "ctgov.faqs" do |t|
      t.integer  "project_id"
      t.string   "question"
      t.text     "answer"
      t.string   "citation"
      t.string   "url"
      t.timestamps null: false
    end

  end

end
