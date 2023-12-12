require 'rails_helper'

RSpec.describe FileRecordsController, type: :controller do
  describe "GET #active_url" do
    context "when file record is found" do
      it "returns http success (204)" do
        create(:file_record, created_at: '2023-03-27', url: 'https://www.example.com')
        get :active_url, params: { type: 'static_db_copies', time: 'daily', filename: '2023-03-27' }, format: :json
        expect(response).to have_http_status(204)
      end
    end

    context "when file record is not found" do
      it "returns not found (404)" do
        get :active_url, params: { type: 'nonexistent_type', time: 'daily', filename: '2023-03-27' }, format: :json
        expect(response).to have_http_status(404)
      end
    end
  end
end

