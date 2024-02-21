require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  before do
    @user = create(:user, admin: true)
    @user.confirm
    sign_in(@user)
  end

  after do
    @user.destroy
  end

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    it "returns http success" do
      test_event = FactoryBot.create(:event)
      get :show, params: {id: test_event.id}
      expect(response).to have_http_status(:success)
    end
  end

end
