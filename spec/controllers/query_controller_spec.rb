require 'rails_helper'

RSpec.describe QueryController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      get :index, query: 'SELECT nct_id, study_type, brief_title, enrollment, has_dmc, completion_date, updated_at FROM studies LIMIT 20'
      expect(response).to have_http_status(:success)
    end
  end

end
