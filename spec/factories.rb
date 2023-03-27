FactoryBot.define do
  factory :user do
    sequence(:email) { |i| "user#{i}@email.com" }
    sequence(:username) { |i| "user#{i}" }
    first_name { 'Firstname' }
    last_name { 'Lastname' }
    password { '1234567' }
    admin { false }
  end

  factory :file_download do
    file_record_id { "MyString" }
    integer { "MyString" }
  end

  factory :file_record, class: 'Core::FileRecord' do
    filename { "20230327export.zip" }
    file_size { 1_400_000 }
    file_type { "snapshot" }
  end
  
  factory :core_study_search, class: 'Core::StudySearch' do
    save_tsv {true}
    query {"AREA[NCTID]NCT23123"}
    grouping {"Causes of Deat"}
    name {"Cancer"}
  end

  factory :core_study_statistics_comparison, class: 'Core::StudyStatisticsComparison' do
    ctgov_selector { "MyText" }
    table { "MyText" }
    column { "MyText" }
    condition { "MyText" }
    instances_query { "SELECT nct_id, study_type, brief_title, enrollment, has_dmc, completion_date, updated_at
                       FROM studies
                       LIMIT 8;" }
    unique_query { "SELECT nct_id, study_type, brief_title, enrollment, has_dmc, completion_date, updated_at
                    FROM studies
                    LIMIT 8;" }
  end

  factory :saved_query do
    title { "MyString" }
    description { "MyString" }
    sql { "MyString" }
    public { false }
  end

  factory :release do
    title { "MyString" }
    subtitle { "MyString" }
    released_on { "2021-11-09 12:01:58" }
    body { "MyText" }
  end

  factory :notice do
    body { "Test notice body" }
    user_id { 1 }
    title { "MyString" }
    send_emails { false }
    emails_sent_at { "2021-10-27 18:07:43" }
    visible { false }
  end

  factory :verifier, class: Core::Verifier do
    differences { [{source: "source", destination: "destination", source_instances: "source_instances", destination_instances: "destination_instances", source_unique_values: "source_unique_values", destination_unique_values: "destination_unique_values"}] }
    source { {source: "source"} }
    last_run { DateTime.now }
    created_at { DateTime.now }
    updated_at  { DateTime.now }
 end

  factory :data_definition do
    db_section { "TEST: protocol" }
    table_name { "TEST: studies" }
    column_name { "TEST: source" }
    data_type { "TEST: string" }
    source { "TEST: <clinical_study>.<source>" }
    ctti_note { "TEST: <clinical_study>.<ctti_note>" }
    nlm_link { "TEST: https://prsinfo.clinicaltrials.gov/definitions.html"}
  end

  factory :event, class: Core::LoadEvent do
    created_at { DateTime.now }
    event_type { "incremental" }
    status { "complete" }
    completed_at { DateTime.now }
    description { "Clinical Study description" }
    problems { "Clinical Study problems" }
  end

  factory :background_job do
    user_id { 18 }
    status { "pending" }
    completed_at { nil }
    logs { "Test: logs"}
    type { "BackgroundJob"}
    data { "SELECT nct_id, study_type, brief_title, enrollment, has_dmc, completion_date, updated_at
            FROM studies
            LIMIT 8" }
    url { "https://digitalocean.files.com/123.csv" }
  end
end