require 'rails_helper'
require 'webmock/rspec'

RSpec.describe SummaryController, type: :controller do
  # binding.pry
  before do
    stub_request(:get, "https://clinicaltrials.gov/api/v2//stats/size").
      with(
        headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Faraday v1.10.3'
        }).
    to_return(status: 200, body: "{}", headers: {})

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
