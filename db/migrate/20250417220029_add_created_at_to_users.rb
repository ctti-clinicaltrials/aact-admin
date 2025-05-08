class AddCreatedAtToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :created_at, :date
  end
end
