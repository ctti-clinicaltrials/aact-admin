FactoryBot.define do
  factory :notice do
    body { "MyString" }
    user_id { 1 }
    title { "MyString" }
    send_emails { false }
    emails_sent_at { "2021-10-27 18:07:43" }
    visible { false }
  end

end
