require 'rails_helper'

RSpec.describe QueryController, type: :controller do

  describe "GET #submit" do
    it "returns http success" do
      get :submit
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #index" do
    it "returns http success" do
      post :index, query: 'SELECT nct_id, study_type, brief_title, enrollment, has_dmc, completion_date, updated_at FROM studies LIMIT 20'
      expect(response).to have_http_status(:success)
    end
  end

end
