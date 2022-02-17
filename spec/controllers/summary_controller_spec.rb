require 'rails_helper'

RSpec.describe SummaryController, type: :controller do

  describe "GET #aact" do
    it "returns http success" do
      get :aact
      expect(response).to have_http_status(:success)
    end
  end

end
