require 'rails_helper'

RSpec.describe Notice, type: :model do
  before do  
    User.destroy_all      
    @user = User.create(email: 'UserEmail@email.com', first_name: 'Firstname', last_name: 'Lastname', username: 'User123', password: '1234567', db_activity: nil, last_db_activity: nil, admin: true)
    @user.confirm
    @notice = Notice.create(body: 'Notice body', title: "Notice title", user_id: @user.id, visible: true, emails_sent_at: nil, send_emails: true)
    @notice1 = Notice.create(body: 'Notice 1 body', title: "Title", user_id: @user.id, visible: false, emails_sent_at: nil, send_emails: false)
    @notice2 = Notice.create(body: 'Notice for sent body', title: "Title", user_id: @user.id, visible: false, emails_sent_at: Time.current, send_emails: true)
  end

  context 'Associations' do
    describe "User" do 
      it "belongs to user" do
        expect(@notice.user_id).to eq(@user.id)
      end  
    end
  end

  context 'Validations' do
    describe "Title" do
      it 'presence_true' do
        notice1 = build :notice, title: nil
        notice2 = build :notice, title: " "
        notice3 = build :notice, title: "title"
        
        expect(notice1).not_to be_valid
        expect(notice2).not_to be_valid
        expect(notice3).to be_valid

        expect(notice1.errors.to_a).to eq ["Title can't be blank"]
        expect(notice2.errors.to_a).to eq ["Title can't be blank"]
        expect(notice3.errors.to_a).to eq []
      end
    end

    describe "User_id" do 
      it 'presence_true' do
        notice1 = build :notice, user_id: nil
        notice2 = build :notice, user_id: " "
        notice3 = build :notice, user_id: @user.id
        
        expect(notice1).not_to be_valid
        expect(notice2).not_to be_valid
        expect(notice3).to be_valid

        expect(notice1.errors.to_a).to eq ["User can't be blank"]
        expect(notice2.errors.to_a).to eq ["User can't be blank"]
        expect(notice3.errors.to_a).to eq []
      end
    end

    describe "Body" do 
      it 'presence_true and length > 10' do
        notice1 = build :notice, body: nil
        notice2 = build :notice, body: " "
        notice3 = build :notice, body: "Body"
        notice4 = build :notice, body: "Notice Body"

        
        expect(notice1).not_to be_valid
        expect(notice2).not_to be_valid
        expect(notice3).not_to be_valid
        expect(notice4).to be_valid

        expect(notice1.errors.to_a).to eq ["Body can't be blank", "Body is too short (minimum is 10 characters)"]
        expect(notice2.errors.to_a).to eq ["Body can't be blank", "Body is too short (minimum is 10 characters)"]
        expect(notice3.errors.to_a).to eq ["Body is too short (minimum is 10 characters)"]
        expect(notice4.errors.to_a).to eq []
      end
    end
  end

  context 'Scopes' do
    describe "Unsent" do 
      it "return notices that are for sending but haven't sent yet" do  
        expect(Notice.unsent).to include(@notice)
        expect(Notice.unsent).not_to include(@notice1, @notice2)
      end
    end

    describe "Sent" do 
      it "return notices that are for sending but and already sent" do
        expect(Notice.sent).to include(@notice2)
        expect(Notice.sent).not_to include(@notice, @notice)
      end
    end
  
    describe "Visible" do 
      it "return notices with visible: true" do  
        expect(Notice.visible).to include(@notice)
        expect(Notice.visible).not_to include(@notice1, @notice2)
      end
    end

    describe "Invisible" do 
      it "return notices with visible: false" do  
        expect(Notice.invisible).to include(@notice1, @notice2)
        expect(Notice.invisible).not_to include(@notice)
      end
    end

  end

  context 'Instance method' do
    describe "Send_notice" do
      it "send notices" do
        @notice.send_notice
        @notice.reload
        expect(@notice.emails_sent_at).not_to eq nil
      end
    end
  end  

end
