require 'rails_helper'

RSpec.describe SummaryController, type: :controller do
  before do
    @user = create(:user, admin: true)
    @user.confirm
    sign_in(@user)
  end

  after do
    @user.destroy
  end

  describe "GET #aact" do
    it "returns http success" do
      get :aact
      expect(response).to have_http_status(:success)
    end
  end

end
