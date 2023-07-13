require 'rails_helper'

RSpec.describe "Verifiers", type: :request do

    describe "GET /verifiers" do
      it "renders the Verifiers index page" do
        get verifiers_path
        expect(response).to be_successful
      end
    end

    describe "GET /verifiers" do
      it "renders the Verifier show page" do
        verify = FactoryBot.create(:verifier)
        get verifier_path(id: verify.id)
        expect(response).to be_successful
      end

      it "redirects to the Verifiers index page if Verifier ID is invalid" do
        get verifier_path(id: 5000) # an ID that doesn't exist
        expect(response).to redirect_to verifiers_path
      end
    end

end    