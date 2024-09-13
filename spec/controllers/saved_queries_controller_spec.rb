require 'rails_helper'

RSpec.describe SavedQueriesController, type: :controller do
  before do
    @user = User.create(email: 'UserEmail@email.com', first_name: 'Firstname', last_name: 'Lastname', username: 'user123', password: '1234567', db_activity: nil, last_db_activity: nil, admin: false)
    # @user.confirm
    sign_in(@user)
    @user2 = User.create(email: 'User2Email@email.com', first_name: 'Firstname', last_name: 'Lastname2', username: 'user12345', password: '1234567', db_activity: nil, last_db_activity: nil, admin: false)
    # @user2.confirm
  end

  after do
    # delete all Queries associated with each User before deleting each User
    @user.saved_queries.each do |query|
      query.destroy
    end
    @user.destroy
    @user2.saved_queries.each do |query|
      query.destroy
    end
    @user2.destroy
  end

  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to render_template(:new)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    it "returns http found" do
      saved_q = FactoryBot.attributes_for(:saved_query)
      post :create, params: { saved_query: saved_q }
      expect(response).to redirect_to saved_query_path(SavedQuery.last)
      expect(response).to have_http_status(:found)
    end
  end

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to render_template(:index)
      expect(response).to have_http_status(:success)
    end

    it "returns http success when searching for queries" do
      saved_q1 = FactoryBot.create(:saved_query, user: @user, title: "Test Query 1", description: "Description 1")
      saved_q2 = FactoryBot.create(:saved_query, user: @user, title: "Test Query 2", description: "Description 2")

      get :index, params: { search: "Test Query" }

      expect(response).to render_template(:index)
      expect(response).to have_http_status(:success)
      expect(assigns(:saved_queries)).to include(saved_q1)
      expect(assigns(:saved_queries)).to include(saved_q2)
    end
  end

  describe "GET #show" do
    it "returns http success" do
      saved_q = FactoryBot.create(:saved_query, user: @user)
      get :show, params: { id: saved_q.id }
      expect(response).to render_template(:show)
      expect(response).to have_http_status(:success)
    end

    it "returns http not found if the Saved Query ID is invalid" do
      get :show, params: { id: 5000 }
      expect(response).to render_template("layouts/application")
      expect(response).to have_http_status(:not_found)
    end

    it "returns http success if the current logged-in User is NOT the User that created the Query and the Query is Public" do
      saved_q = FactoryBot.create(:saved_query, user: @user2, public: true)
      get :show, params: { id: saved_q.id }
      expect(response).to render_template(:show)
      expect(response).to have_http_status(:success)
    end

    it "returns http not found if the current logged-in User is NOT the User that created the Query and the Query is Not Public" do
      saved_q = FactoryBot.create(:saved_query, user: @user2)
      get :show, params: { id: saved_q.id }
      expect(response).to render_template("layouts/application")
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET #edit" do
    it "returns http success if the current logged-in User is the User that created the Query" do
      saved_q = FactoryBot.create(:saved_query, user: @user)
      get :edit, params: { id: saved_q.id }
      expect(response).to render_template(:edit)
      expect(response).to have_http_status(:success)
    end

    it "returns http not found if the current logged-in User is NOT the User that created the Query" do
      saved_q = FactoryBot.create(:saved_query, user: @user2)
      get :edit, params: { id: saved_q.id }
      expect(response).to render_template("layouts/application")
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PUT #update" do
    it "returns http found" do
      saved_q = FactoryBot.create(:saved_query, user: @user)
      put :update, params: { id: saved_q.id, saved_query: { public: "true" } }
      expect(response).to redirect_to saved_query_path(saved_q)
      expect(response).to have_http_status(:found)
    end

    it "returns http not found if the current logged-in User is NOT the User that created the Query" do
      saved_q = FactoryBot.create(:saved_query, user: @user2)
      put :update, params: { id: saved_q.id, saved_query: { public: "true" } }
      expect(response).to render_template("layouts/application")
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE #destroy" do
    it "returns http found if the current logged-in User is the User that created the Query" do
      saved_q = FactoryBot.create(:saved_query, user: @user)
      delete :destroy, params: { id: saved_q.id }
      expect(response).to redirect_to saved_queries_path
      expect(response).to have_http_status(:found)
    end

    it "returns http not found if the current logged-in User is NOT the User that created the Query" do
      saved_q = FactoryBot.create(:saved_query, user: @user2)
      delete :destroy, params: { id: saved_q.id }
      expect(response).to render_template("layouts/application")
      expect(response).to have_http_status(:not_found)
    end
  end
end
