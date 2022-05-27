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

 factory :verifier do
  source {"ProtocolSection|IdentificationModule|NCTId"}
  destination {"studies#nct_id"}
  source_instances {415358}
  destination_instances {0}
  source_unique_values {0}
  destination_unique_values {0}
 end
end
