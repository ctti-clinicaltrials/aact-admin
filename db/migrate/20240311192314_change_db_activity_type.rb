class ChangeDbActivityType < ActiveRecord::Migration[5.0]
  def change
    change_column :users, :db_activity, :bigint
  end
end
