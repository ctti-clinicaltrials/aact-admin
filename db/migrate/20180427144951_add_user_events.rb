class AddUserEvents < ActiveRecord::Migration[6.0]
  def change

    create_table "ctgov.user_events" do |t|
      t.string   "email"
      t.string   "event_type"
      t.text     "description"
      t.string   "file_names"
      t.timestamps null: false
    end

  end
end
