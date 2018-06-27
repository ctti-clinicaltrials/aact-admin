class AddUserEvents < ActiveRecord::Migration
  def change

    create_table "admin.user_events" do |t|
      t.string   "email"
      t.string   "event_type"
      t.text     "description"
      t.string   "file_names"
      t.timestamps null: false
    end

  end
end
