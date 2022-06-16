require 'rails_helper'

RSpec.describe VerifiersController, type: :controller do
  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
  let(:verifier) { FactoryBot.create(:verifier)}
    it "returns http success" do
      get :show, id: verifier.id
      expect(response).to have_http_status(:success)
    end
  end
end