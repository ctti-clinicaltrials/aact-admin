require 'rails_helper'

RSpec.describe QueryController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #submit" do
    it "returns http success" do
      get :submit
      expect(response).to have_http_status(:success)
    end
  end

end
