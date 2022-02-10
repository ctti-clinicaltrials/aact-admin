require "rails_helper"

RSpec.describe NoticeMailer, type: :mailer do
  describe "notice_to_mail" do
    let(:mail) { NoticeMailer.notice_to_mail }

    # it "renders the headers" do
    #   expect(mail.subject).to eq("Notice to mail")
    #   expect(mail.to).to eq(["to@example.org"])
    #   expect(mail.from).to eq(["from@example.com"])
    # end

    # it "renders the body" do
    #   expect(mail.body.encoded).to match("Hi")
    # end
  end

end
