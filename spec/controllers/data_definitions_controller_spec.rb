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
      post :create, 
            data_definition: { db_section: "TEST: protocol",
                               table_name: "TEST: studies",
                               column_name: "TEST: source",
                               data_type: "TEST: string",
                               source: "TEST: <clinical_study>.<source>",
                               nlm_link: "TEST: https://prsinfo.clinicaltrials.gov/definitions.html" }
      expect(response).to redirect_to data_definitions_path
      expect(response).to have_http_status(:found)
    end
  end

  # describe "POST #create" do
  #   it "returns http found" do
  #     data_def = FactoryBot.create(:data_definition)
  #     post :create, data_definition: data_def
  #     # data_def.dig(:db_section, :table_name, :column_name, :data_type, :source, :nlm_link)
  #     expect(response).to redirect_to data_definitions_path
  #     expect(response).to have_http_status(:found)
  #   end
  # end

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

  # describe "PUT #update" do
  #   it "returns http success" do
  #     data_def = FactoryBot.create(:data_definition)
  #     data_def.update(db_section: "TEST: results")
  #     # expect(response).to redirect_to data_definitions_path
  #     expect(response).to have_http_status(:success)
  #   end
  # end

end