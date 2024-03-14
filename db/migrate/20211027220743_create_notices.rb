class CreateNotices < ActiveRecord::Migration[4.2]
  def change
    create_table :notices do |t|
      t.string :body
      t.integer :user_id
      t.string :title
      t.boolean :send_emails
      t.datetime :emails_sent_at
      t.boolean :visible

      t.timestamps
    end
  end
end
