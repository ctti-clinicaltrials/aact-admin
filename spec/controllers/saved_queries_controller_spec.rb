require 'rails_helper'

RSpec.describe SavedQueriesController, type: :controller do
  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to render_template(:new)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    it "returns http found" do
      @user = User.create(email: 'Jackie.Robinson42@email.com', first_name: 'Jackie', last_name: 'Robinson', username: 'jackierobinson42', password: 'Dodgers', db_activity: nil, last_db_activity: nil, admin: false)
      @user.confirm
      sign_in(@user)
      saved_q = FactoryBot.attributes_for(:saved_query)
      post :create, saved_query: saved_q
      expect(response).to redirect_to saved_query_path
      expect(response).to have_http_status(:found)
      @user.destroy
    end
  end

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to render_template(:index)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    it "returns http success" do
      saved_q = FactoryBot.create(:saved_query)
      get :show, id: saved_q.id
      expect(response).to render_template(:show)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #edit" do
    it "returns http success" do
      @user = User.create(email: 'Sandy.Koufax32@email.com', first_name: 'Sandy', last_name: 'Koufax', username: 'sandykoufax32', password: 'Dodgers', db_activity: nil, last_db_activity: nil, admin: false)
      @user.confirm
      sign_in(@user)
      saved_q = FactoryBot.create(:saved_query)
      get :edit, id: saved_q.id
      expect(response).to render_template(:edit)
      expect(response).to have_http_status(:success)
      @user.destroy
    end
  end

  describe "PUT #update" do
    it "returns http found" do
      saved_q = FactoryBot.create(:saved_query)
      put :update, id: saved_q.id, saved_query: { "public"=>"true" }
      expect(response).to redirect_to (@saved_query)
      expect(response).to have_http_status(:found)
    end
  end

  describe "DELETE #destroy" do
    it "returns http success" do
      @user = User.create(email: 'Clayton.Kershaw22@email.com', first_name: 'Clayton', last_name: 'Kershaw', username: 'claytonkershaw22', password: 'Dodgers', db_activity: nil, last_db_activity: nil, admin: false)
      @user.confirm
      sign_in(@user)
      saved_q = FactoryBot.create(:saved_query)
      delete :destroy, id: saved_q.id
      expect(response).to redirect_to (:index)
      expect(response).to have_http_status(:success)
      @user.destroy
    end
  end

end
