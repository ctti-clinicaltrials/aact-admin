require 'rails_helper'

RSpec.describe StudyStatisticsComparisonsController, type: :controller do

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
      study_stat_comp = FactoryBot.attributes_for(:core_study_statistics_comparison)
      post :create, core_study_statistics_comparison: study_stat_comp
      expect(response).to have_http_status(:found)
    end
  end

  describe "GET #edit" do
    it "returns http success" do
      study_stat_comp = FactoryBot.create(:core_study_statistics_comparison)
      get :edit, id: study_stat_comp.id
      expect(response).to have_http_status(:success)
    end
  end

  describe "PUT #update" do
    it "returns http found" do
      study_stat_comp = FactoryBot.create(:core_study_statistics_comparison)
      put :update, id: study_stat_comp.id, core_study_statistics_comparison: { "ctgov_selector"=>"Test CTGOV Selector" }
      expect(response).to have_http_status(:found)
    end
  end

  describe "DELETE #destroy" do
    it "returns http found" do
      study_stat_comp = FactoryBot.create(:core_study_statistics_comparison)
      delete :destroy, id: study_stat_comp.id
      expect(response).to have_http_status(:found)
    end
  end

end
