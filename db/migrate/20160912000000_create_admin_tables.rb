class CreateAdminTables < ActiveRecord::Migration

  def change

    create_table "admin.public_announcements", force: :cascade do |t|
      t.string   "description"
      t.boolean  "is_sticky"
    end

    create_table "admin.data_definitions" do |t|
      t.string 'db_section'
      t.string 'table_name'
      t.string 'column_name'
      t.string 'data_type'
      t.string 'source'
      t.text   'ctti_note'
      t.string 'nlm_link'
      t.integer 'row_count'
      t.json   'enumerations'
      t.timestamps null: false
    end

    create_table "admin.use_cases" do |t|
      t.string  'status'  # public or not?
      t.date    'completion_date'
      t.string  'title'
      t.integer 'year'
      t.string  'brief_summary'
      t.string  'investigators'
      t.string  'organizations'
      t.string  'url'
      t.text    'detailed_description'
      t.text    'protocol'
      t.text    'issues'
      t.text    'study_selection_criteria'
      t.string  'submitter_name'
      t.string  'contact_info'
      t.string  'email'
      t.binary  'image'
      t.timestamps null: false
    end

    create_table "admin.use_case_attachments" do |t|
      t.integer 'use_case_id'
      t.string 'file_name'
      t.string 'content_type'
      t.binary 'file_contents'
      t.boolean 'is_image'
      t.timestamps null: false
    end

    create_table "admin.use_case_publications", force: :cascade do |t|
      t.integer "use_case_id"
      t.string  "name"
      t.string  "url"
    end

    create_table "admin.use_case_datasets", force: :cascade do |t|
      t.integer "use_case_id"
      t.string  "dataset_type"  # support, results
      t.string  "name"
      t.text    "description"
    end

    #add_foreign_key "admin.use_case_publications", "admin.use_cases"
    #add_foreign_key "admin.use_case_datasets", "admin.use_cases"
    add_index "admin.use_cases", :organizations
    add_index "admin.use_cases", :completion_date
    add_index "admin.use_cases", :year
    add_index "admin.use_case_datasets", :dataset_type
    add_index "admin.use_case_datasets", :name

  end

end
