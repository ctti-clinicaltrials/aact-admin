require 'rails_helper'

RSpec.describe "Notices", type: :request do

  context "If User is an admin" do
    before do 
      User.destroy_all      
      @user = User.create(email: 'UserEmail@email.com', first_name: 'Firstname', last_name: 'Lastname', username: 'User123', password: '1234567', db_activity: nil, last_db_activity: nil, admin: true)
      @user.confirm
      sign_in(@user)
    end

    describe "GET /admin/notices" do
      it "renders :index" do
        get admin_notices_path
        expect(response).to render_template(:index)
      end
    end

    describe "GET /admin/notice" do
      it "renders :show page" do
        notice = FactoryBot.create(:notice)
        get admin_notice_path(id: notice.id)
        expect(response).to render_template(:show)
      end

      it "redirects to :index page if id is invalid" do
        get admin_notice_path(id: 5000)
        expect(response).to redirect_to admin_notices_path
      end
    end

    describe "GET /admin/notices/new" do
      it "renders :new page" do
        get "/admin/notices/new"
        expect(response).to render_template(:new)
      end

      it " doesn't render :show page" do
        get "/admin/notices/new"
        expect(response).to_not render_template(:show)
      end

    end

    describe "GET /admin/notices/:id/edit" do
      it "renders :edit page" do
        notice = FactoryBot.create(:notice)
        get edit_admin_notice_path(id: notice.id)
        expect(response).to render_template(:edit)
      end
    end

    describe "POST /admin/notice with valid data" do
      it "creates a new notice and redirects to the show page if attributes are valid" do
        params = { notice: {title: 'Test', body: 'Notice test body', send_emails: false} }
        expect { post admin_notices_path, params }.to change(Notice, :count)
        expect(response).to redirect_to admin_notice_path(id: Notice.last.id)
      end
    end

    describe "POST /admin/notice with invalid data" do
      it "does not save a new Notice and redirects" do
        params = { notice: {title: ' ', body: 'Notice test body', send_emails: false} }
        expect { post admin_notices_path, params }.to_not change(Notice, :count)
        expect(response).to render_template(:new)
      end
    end

    describe "PUT /admin/notice with valid data" do
      it "updates a notice with valid attributes and redirects to the show page " do
        notice = FactoryBot.create(:notice)
        put admin_notice_path(id: notice.id), notice: {visible: true}
        notice.reload
        expect(notice.visible).to eq true
        expect(response).to redirect_to admin_notice_path(id: notice.id)
      end
    end

    describe "PUT /admin/notice with invalid data" do
      it "does not updates a notice with invalid attributes and redirect to the edit page" do
        notice = FactoryBot.create(:notice)
        put admin_notice_path(id: notice.id), notice: {body: " "}
        notice.reload
        expect(notice.body).not_to eq(" ")
        expect(response).to render_template(:edit)
      end
    end

    describe "DELETE /admin/notices/ " do
      it "deletes a notice from Notices" do
        notice = FactoryBot.create(:notice)
        expect {delete admin_notice_path(id: notice.id)}.to change(Notice, :count).by(-1)
        expect(response).to redirect_to admin_notices_path
      end
    end

    describe "GET /admin/notices/:id/send_notices" do
      it "sends notice and redirects to :show page" do
        notice=Notice.create(title: "Title", body: "Notice body", user_id: @user.id, visible: false, send_emails: true, emails_sent_at: nil)
        get "/admin/notices/#{notice.id}/send_notice"
        notice.reload
        expect(notice.emails_sent_at).to_not eq nil
        expect(response).to redirect_to admin_notice_path(notice.id)
      end

    end

  end

  context "If User is a non-admin" do
    before do # Had to set it to call for each test because of database connection error
      User.destroy_all
      @user = User.create(email: 'Javier.Jimenez@email.com', first_name: 'Javier', last_name: 'Jimenez', username: 'JavierJimenez2022', password: '1234567', db_activity: nil, last_db_activity: nil, admin: false)
      @user.confirm
      sign_in(@user)
    end

    describe "GET /admin/notices" do
      it "redirects to the home page if user is not an admin" do
        get admin_notices_path
        expect(response).to redirect_to root_path
      end
    end

    describe "GET /admin/notice" do
      it "redirects to the home page if user is not an admin" do
        get admin_notice_path(id: 5)
        expect(response).to redirect_to admin_notices_path
      end
    end

    describe "GET /admin/notices/new" do
      it "redirects to the home page if user is not an admin" do
        get "/admin/notices/new"
        expect(response).to redirect_to root_path     
       end
    end

    describe "GET /admin/notices/:id/edit" do
      it "redirects to the home page if user is not an admin" do
        get edit_admin_notice_path(id: 5)
        expect(response).to redirect_to admin_notices_path
      end
    end

    describe "POST /admin/notice " do
      it "redirects to the home page if user is not an admin" do
        params = { notice: {title: 'Test', body: 'Notice test body', send_emails: false} }
        expect { post admin_notices_path, params }.to_not change(Notice, :count)
        expect(response).to redirect_to root_path     
      end
    end

    describe "POST /admin/notice with invalid data" do
      it "redirects to the home page if user is not an admin" do
        params = { notice: {title: ' ', body: 'Notice test body', send_emails: false} }
        expect { post admin_notices_path, params }.to_not change(Notice, :count)
        expect(response).to redirect_to root_path     
      end
    end

    describe "PUT /admin/notice with valid data" do
      it "redirects to the home page if user is not an admin " do
        notice = FactoryBot.create(:notice)
        put admin_notice_path(id: notice.id), notice: {visible: true}
        notice.reload
        expect(notice.visible).to eq false
        expect(response).to redirect_to root_path   
      end
    end

    describe "PUT /admin/notice with invalid data" do
      it "does not updates a notice with invalid attributes and redirect to the home page" do
        notice = FactoryBot.create(:notice)
        put admin_notice_path(id: notice.id), notice: {body: " "}
        notice.reload
        expect(notice.body).not_to eq(" ")
        expect(response).to redirect_to root_path   
      end
    end

    describe "DELETE /admin/notices/ " do
      it "does not delete a notice and redirects to the home page" do
        expect {delete admin_notice_path(id: 5)}.to_not change(Notice, :count)
        expect(response).to redirect_to admin_notices_path
      end
    end  
  end

  context "If User is not logged in" do
    describe "GET /admin/notices" do
      it "redirects to the home page if user is not logged in" do
        get admin_notices_path
        expect(response).to redirect_to root_path
      end
    end

    describe "GET /admin/notice/" do
      it "redirects to the home page if user is not logged in" do
        get admin_notice_path(id: 6)
        expect(response).to redirect_to admin_notices_path
      end
    end

    describe "GET /admin/notice/new" do
      it "redirects to the home page if user is not logged in" do
        get "/admin/notices/new"
        expect(response).to redirect_to root_path  
      end
    end

    describe "GET /admin/notice/:id/edit" do
      it "redirects to the home page if user is not logged in" do
        get edit_admin_notice_path(id: 5)
        expect(response).to redirect_to admin_notices_path
      end
    end

    describe "POST /admin/notice with valid data" do
      it "redirects to the home page if user is not logged in" do
        params = { notice: {title: 'Test', body: 'Notice test body', send_emails: false} }
        expect { post admin_notices_path, params }.to_not change(Notice, :count)
        expect(response).to redirect_to root_path
      end
    end

    describe "PUT /admin/notice/ with valid data" do
      it "redirects to the home page if user is not logged in" do
        put admin_notice_path(id: 3), notice: {send_emails: true}
        expect(response).to redirect_to admin_notices_path
      end
    end

    describe "DELETE /release " do
      it "redirects to the home page if user is not logged in" do
        delete admin_notice_path(id: 18)
        expect(response).to redirect_to admin_notices_path
      end
    end
  end
end
