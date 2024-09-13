require 'rails_helper'

RSpec.describe "Releases", type: :request do
  context "If User is an admin" do
    before do # Had to set it to call for each test because of database connection error
      User.destroy_all
      @user = User.create(email: 'Javier.Jimenez@email.com', first_name: 'Javier', last_name: 'Jimenez', username: 'JavierJimenez2022', password: '1234567', db_activity: nil, last_db_activity: nil, admin: true)
      # @user.confirm
      sign_in(@user)
    end

    describe "GET /releases" do
      it "renders the Releases index page" do
        get releases_path
        expect(response).to render_template(:index)
      end
    end

    describe "GET /release" do
      it "renders the Release show page" do
        release = FactoryBot.create(:release)
        get release_path(id: release.id)
        expect(response).to render_template(:show)
      end
      it "redirects to the Releases index page if the Release ID is invalid" do
        get release_path(id: 5000) # an ID that doesn't exist
        expect(response).to redirect_to releases_path
      end
    end

    describe "GET /releases/new" do
      it "renders the Releases new page" do
        get new_release_path
        expect(response).to render_template(:new)
      end
    end

    describe "GET /releases/:id/edit" do
      it "renders the Releases edit page" do
        release = FactoryBot.create(:release)
        get edit_release_path(id: release.id)
        expect(response).to render_template(:edit)
      end
    end

    describe "POST /releases/ with valid data" do
      it "saves a new Release and redirects to the show page if valid attributes" do
        release_attributes = { release: {title: 'Code the Dream', subtitle: 'AACT', released_on: Date.today, body: 'Testing valid data.'} }
        expect { post releases_path(release_attributes)}.to change(Release, :count)
        expect(response).to redirect_to release_path(id: Release.last.id)
      end
    end

    describe "POST /release/ with invalid data" do
      it "does not save a new Release or redirect if invalid title" do
        release_attributes = { release: {title: '', subtitle: 'subtitle', released_on: Date.today, body: 'body'} }
        expect { post releases_path(release_attributes) }.to_not change(Release, :count)
        expect(response).to render_template(:new)
      end
      it "does not save a new Release or redirect if invalid subtitle" do
        release_attributes = { release: {title: 'title', subtitle: '', released_on: Date.today, body: 'body'} }
        expect { post releases_path(release_attributes) }.to_not change(Release, :count)
        expect(response).to render_template(:new)
      end
      it "does not save a new Release or redirect if invalid released on date" do
        release_attributes = { release: {title: 'title', subtitle: 'subtitle', released_on: 18, body: 'body'} }
        expect { post releases_path(release_attributes) }.to_not change(Release, :count)
        expect(response).to render_template(:new)
      end
      it "does not save a new Release or redirect if invalid body" do
        release_attributes = { release: {title: 'title', subtitle: 'subtitle', released_on: Date.today, body: ''} }
        expect { post releases_path(release_attributes) }.to_not change(Release, :count)
        expect(response).to render_template(:new)
      end
    end

    describe "PUT /release/ with valid data" do
      it "updates a Release and redirects to the show page if valid attribute" do
        release = FactoryBot.create(:release)
        put release_path(release.id), params: {release: {released_on: Date.today}}
        release.reload
        expect(release.released_on).to eq(Date.today)
        expect(response).to redirect_to release_path(release.id)
      end
    end

    describe "PUT /release/ with invalid data" do
      it "does not update the Release or redirect if invalid title" do
        release = FactoryBot.create(:release)
        put release_path(release.id), params: {release: {title: ''}}
        release.reload
        expect(release.title).not_to eq('')
        expect(response).to render_template(:edit)
      end
      it "does not update the Release or redirect if invalid subtitle" do
        release = FactoryBot.create(:release)
        put release_path(release.id), params: {release: {subtitle: ''}}
        release.reload
        expect(release.released_on).not_to eq('')
        expect(response).to render_template(:edit)
      end
      it "does not update the Release or redirect if invalid released on date" do
        release = FactoryBot.create(:release)
        put release_path(release.id), params: {release: {released_on: 18}}
        release.reload
        expect(release.released_on).not_to eq(Date.today)
        expect(response).to render_template(:edit)
      end
      it "does not update the Release or redirect if invalid body" do
        release = FactoryBot.create(:release)
        put release_path(release.id), params: {release: {body: ''}}
        release.reload
        expect(release.released_on).not_to eq('')
        expect(response).to render_template(:edit)
      end
    end

    describe "DELETE /release " do
      it "deletes a Release from Releases" do
        release = FactoryBot.create(:release)
        delete release_path(release.id)
        expect(response).to redirect_to releases_path
      end
    end
  end

  context "If User is a non-admin" do
    before do # Had to set it to call for each test because of database connection error
      User.destroy_all
      @user = User.create(email: 'Javier.Jimenez@email.com', first_name: 'Javier', last_name: 'Jimenez', username: 'JavierJimenez2022', password: '1234567', db_activity: nil, last_db_activity: nil, admin: false)
      # @user.confirm
      sign_in(@user)
    end

    describe "GET /releases" do
      it "redirects to the home page if user is not an admin" do
        get releases_path
        expect(response).to redirect_to root_path
      end
    end

    describe "GET /release" do
      it "redirects to the home page if user is not an admin" do
        get release_path(id: 1)
        expect(response).to redirect_to releases_path
      end
    end

    describe "GET /releases/new" do
      it "redirects to the home page if user is not an admin" do
        get new_release_path
        expect(response).to redirect_to root_path
      end
    end

    describe "GET /releases/:id/edit" do
      it "redirects to the home page if user is not an admin" do
        get edit_release_path(id: 2)
        expect(response).to redirect_to releases_path
      end
    end

    describe "POST /releases/ with valid data" do
      it "redirects to the home page if user is not an admin" do
        release_attributes = { release: {title: 'Code the Dream', subtitle: 'AACT', released_on: Date.today, body: 'Testing valid data.'} }
        expect { post releases_path(release_attributes) }.to_not change(Release, :count)
        expect(response).to redirect_to root_path
      end
    end

    describe "PUT /release/ with valid data" do
      it "redirects to the home page if user is not an admin" do
        put release_path(id: 3),params: { release: {released_on: Date.today}}
        expect(response).to redirect_to releases_path
      end
    end

    describe "DELETE /release " do
      it "redirects to the home page if user is not an admin" do
        expect {delete release_path(id: 5)}.to_not change(Release, :count)  
        expect(response).to redirect_to releases_path
      end
    end
  end

  context "If User is not logged in" do
    describe "GET /releases" do
      it "redirects to the home page if user is not logged in" do
        get releases_path
        expect(response).to redirect_to root_path
      end
    end

    describe "GET /release" do
      it "redirects to the home page if user is not logged in" do
        get release_path(id: 1)
        expect(response).to redirect_to releases_path
      end
    end

    describe "GET /releases/new" do
      it "redirects to the home page if user is not logged in" do
        get new_release_path
        expect(response).to redirect_to root_path
      end
    end

    describe "GET /releases/:id/edit" do
      it "redirects to the home page if user is not logged in" do
        get edit_release_path(id: 2)
        expect(response).to redirect_to releases_path
      end
    end

    describe "POST /releases/ with valid data" do
      it "redirects to the home page if user is not logged in" do
        release_attributes = { release: {title: 'Code the Dream', subtitle: 'AACT', released_on: Date.today, body: 'Testing valid data.'} }
        expect { post releases_path(release_attributes) }.to_not change(Release, :count)
        expect(response).to redirect_to root_path
      end
    end

    describe "PUT /release/ with valid data" do
      it "redirects to the home page if user is not logged in" do
        put release_path(id: 3),params: { release: {released_on: Date.today}}
        expect(response).to redirect_to releases_path
      end
    end

    describe "DELETE /release " do
      it "redirects to the home page if user is not logged in" do
        expect {delete release_path(id: 5)}.to_not change(Release, :count)  
        expect(response).to redirect_to releases_path
      end
    end
  end


end
