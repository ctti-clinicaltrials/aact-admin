require 'rails_helper'

RSpec.describe StudySearchesController, type: :controller do
    
    describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    it "returns http found" do
     study_search_test = FactoryBot.attributes_for(:core_study_search)
      post :create, core_study_search: study_search_test
      expect(response).to have_http_status(:found)
    end
  end

  describe "GET #edit" do
    it "returns http success" do
     study_search_test = FactoryBot.create(:core_study_search)
      get :edit, id: study_search_test.id
      expect(response).to have_http_status(:success)
    end
  end

  describe "PUT #update" do
    it "returns http found" do
     study_search_test = FactoryBot.create(:core_study_search)
      put :update, id: study_search_test.id, core_study_search: { "save_tsv"=>"false" }
      expect(response).to have_http_status(:found)
    end
  end

  describe "DELETE #destroy" do
    it "returns http found" do
     study_search_test = FactoryBot.create(:core_study_search)
      delete :destroy, id: study_search_test.id
      expect(response).to have_http_status(:found)
    end
  end

end
