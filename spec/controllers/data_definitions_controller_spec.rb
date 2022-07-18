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
    it "returns http success" do
      post :create, data_definition: {"db_section"=>"TEST: protocol", 
                                      "table_name"=>"TEST: studies", 
                                      "column_name"=>"TEST: source", 
                                      "data_type"=>"TEST: string", 
                                      "source"=>"TEST: <clinical_study>.<source>",
                                      "nlm_link"=>"TEST: https://prsinfo.clinicaltrials.gov/definitions.html"}
      expect(response).to redirect_to data_definitions_path
      expect(response).to have_http_status(:found)
    end
  end

end