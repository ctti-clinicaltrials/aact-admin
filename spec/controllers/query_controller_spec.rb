require 'rails_helper'

RSpec.describe QueryController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #submit" do
    it "returns http success" do
      post :submit, query: 'SELECT nct_id, study_type, completion_date FROM studies LIMIT 5'
      expect(response).to have_http_status(:success)
    end
  end

end
