class CreateFileDownloads < ActiveRecord::Migration
  def change
    create_table :file_downloads do |t|
      t.integer :file_record_id     
      t.integer :count, :default => 0
      t.timestamps
    end
  end
end


