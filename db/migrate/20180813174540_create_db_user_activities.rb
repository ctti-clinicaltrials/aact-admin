class CreateDbUserActivities < ActiveRecord::Migration[6.0]
  def change
    create_table "ctgov.db_user_activities" do |t|
      t.string    :username
      t.integer   :event_count
      t.datetime  :when_recorded
      t.string    :unit_of_time   # daily, weekly, monthly?
      t.timestamps null: false
    end

    add_column :users, :db_activity, :integer
    add_column :users, :last_db_activity, :datetime
  end
end
