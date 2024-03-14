class CreateFileDownloads < ActiveRecord::Migration[4.2]
  def change
    create_table :file_downloads do |t|
      t.integer :file_record_id     
      t.timestamps
    end
  end
end


