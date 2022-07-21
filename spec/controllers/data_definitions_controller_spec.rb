require 'rails_helper'

RSpec.describe DataDefinitionsController, type: :controller do
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
      data_def = FactoryBot.attributes_for(:data_definition)
      post :create, data_definition: data_def
      expect(response).to redirect_to data_definitions_path
      expect(response).to have_http_status(:found)
    end
  end

  describe "GET #edit" do
    it "returns http success" do
      data_def = FactoryBot.create(:data_definition)
      get :edit, id: data_def.id
      expect(response).to render_template(:edit)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PUT #update" do
    it "returns http found" do
      data_def = FactoryBot.create(:data_definition)
      put :update, id: data_def.id, data_definition: { "db_section"=>"TEST: results" }
      expect(response).to redirect_to data_definitions_path
      expect(response).to have_http_status(:found)
    end
  end

  describe "GET #show" do
    it "returns http success" do
      data_def = FactoryBot.create(:data_definition)
      get :show, id: data_def.id
      expect(response).to render_template(:show)
      expect(response).to have_http_status(:success)
    end
  end
end