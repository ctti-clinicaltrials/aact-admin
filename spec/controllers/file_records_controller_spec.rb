require 'rails_helper'

RSpec.describe FileRecordsController, type: :controller do

  describe "GET #active_url" do
    it "returns http success" do
      create(:file_record, created_at: '2023-03-27')
      get :active_url, { type: 'static_db_copies', time: 'daily', filename: '2023-03-27' }
      expect(response).to have_http_status(302)
    end
  end

end
