require 'rails_helper'

RSpec.describe Admin::NoticesController, type: :controller do

  describe "GET #notices" do
    it "returns http success" do
      get "/admin/notices"
      expect(response).to have_http_status(:success)
    end
  end

end
