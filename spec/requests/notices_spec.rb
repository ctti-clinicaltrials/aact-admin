require 'rails_helper'

RSpec.describe "Notices", type: :request do

  context "If User is an admin" do
    before do 
      User.destroy_all
      @user = User.create(email: 'Javier.Jimenez@email.com', first_name: 'Javier', last_name: 'Jimenez', username: 'JavierJimenez2022', password: '1234567', db_activity: nil, last_db_activity: nil, admin: true)
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
      it "does not save a new Release or redirect if invalid title" do
        params = { notice: {title: ' ', body: 'Notice test body', send_emails: false} }
        expect { post admin_notices_path, params }.to_not change(Release, :count)
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
  end
  #   describe "DELETE /release " do
  #     it "deletes a Release from Releases" do
  #       release = FactoryBot.create(:release)
  #       delete release_path(release.id)
  #       expect(response).to redirect_to releases_path
  #     end
  #   end
  # end

  # context "If User is a non-admin" do
  #   before do # Had to set it to call for each test because of database connection error
  #     User.destroy_all
  #     @user = User.create(email: 'Javier.Jimenez@email.com', first_name: 'Javier', last_name: 'Jimenez', username: 'JavierJimenez2022', password: '1234567', db_activity: nil, last_db_activity: nil, admin: false)
  #     @user.confirm
  #     sign_in(@user)
  #   end

  #   describe "GET /releases" do
  #     it "redirects to the home page if user is not an admin" do
  #       get releases_path
  #       expect(response).to redirect_to root_path
  #     end
  #   end

  #   describe "GET /release" do
  #     it "redirects to the home page if user is not an admin" do
  #       get release_path(id: 1)
  #       expect(response).to redirect_to root_path
  #     end
  #   end

  #   describe "GET /releases/new" do
  #     it "redirects to the home page if user is not an admin" do
  #       get new_release_path
  #       expect(response).to redirect_to root_path
  #     end
  #   end

  #   describe "GET /releases/:id/edit" do
  #     it "redirects to the home page if user is not an admin" do
  #       get edit_release_path(id: 2)
  #       expect(response).to redirect_to root_path
  #     end
  #   end

  #   describe "POST /releases/ with valid data" do
  #     it "redirects to the home page if user is not an admin" do
  #       release_attributes = { release: {title: 'Code the Dream', subtitle: 'AACT', released_on: Date.today, body: 'Testing valid data.'} }
  #       expect { post releases_path, release_attributes }.to_not change(Release, :count)
  #       expect(response).to redirect_to root_path
  #     end
  #   end

  #   describe "PUT /release/ with valid data" do
  #     it "redirects to the home page if user is not an admin" do
  #       put release_path(id: 3), release: {released_on: Date.today}
  #       expect(response).to redirect_to root_path
  #     end
  #   end

  #   describe "DELETE /release " do
  #     it "redirects to the home page if user is not an admin" do
  #       delete release_path(id: 18)
  #       expect(response).to redirect_to root_path
  #     end
  #   end
  # end

  # context "If User is not logged in" do
  #   describe "GET /releases" do
  #     it "redirects to the home page if user is not logged in" do
  #       get releases_path
  #       expect(response).to redirect_to root_path
  #     end
  #   end

  #   describe "GET /release" do
  #     it "redirects to the home page if user is not logged in" do
  #       get release_path(id: 1)
  #       expect(response).to redirect_to root_path
  #     end
  #   end

  #   describe "GET /releases/new" do
  #     it "redirects to the home page if user is not logged in" do
  #       get new_release_path
  #       expect(response).to redirect_to root_path
  #     end
  #   end

  #   describe "GET /releases/:id/edit" do
  #     it "redirects to the home page if user is not logged in" do
  #       get edit_release_path(id: 2)
  #       expect(response).to redirect_to root_path
  #     end
  #   end

  #   describe "POST /releases/ with valid data" do
  #     it "redirects to the home page if user is not logged in" do
  #       release_attributes = { release: {title: 'Code the Dream', subtitle: 'AACT', released_on: Date.today, body: 'Testing valid data.'} }
  #       expect { post releases_path, release_attributes }.to_not change(Release, :count)
  #       expect(response).to redirect_to root_path
  #     end
  #   end

  #   describe "PUT /release/ with valid data" do
  #     it "redirects to the home page if user is not logged in" do
  #       put release_path(id: 3), release: {released_on: Date.today}
  #       expect(response).to redirect_to root_path
  #     end
  #   end

  #   describe "DELETE /release " do
  #     it "redirects to the home page if user is not logged in" do
  #       delete release_path(id: 18)
  #       expect(response).to redirect_to root_path
  #     end
  #   end
  # end


end
