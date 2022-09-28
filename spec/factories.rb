FactoryBot.define do
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
    differences {{source: "source", destination: "destination", source_instances: "source_instances", destination_instances: "destination_instances", source_unique_values: "source_unique_values", destination_unique_values: "destination_unique_values"}}
    source {{source: "source"}}
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
end