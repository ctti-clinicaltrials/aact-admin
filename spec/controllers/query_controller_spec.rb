require 'rails_helper'

RSpec.describe QueryController, type: :controller do

  describe "GET #index" do
    it "returns http success with an invalid SQL Query" do
      get :index, query: 'SELECT nct_id, study_type, brief_title, enrollment, has_dmc, completion_date, updated_at FROM LIMIT 20'
      expect(response).to have_http_status(:success)
    end
  end
  
  describe "GET #index" do
    it "returns http success" do
      get :index, query: 'SELECT nct_id, study_type, brief_title, enrollment, has_dmc, completion_date, updated_at FROM studies LIMIT 20'
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #index" do
    it "format html file, returns http success" do
      get :index, format: :html, query: 'SELECT nct_id, study_type, brief_title, enrollment, has_dmc, completion_date, updated_at FROM studies LIMIT 5'
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #index" do
    #  Can't create a study because Public::Study is READONLY, need to write SQL explicitly
    before(:each) do
      Query::Base.connection.execute("INSERT INTO studies(nct_id, brief_title, created_at, updated_at) VALUES('1238','hello', '2018-10-31', '2018-12-25')")
    end
    
    after(:each) do
      Query::Base.connection.execute("DELETE FROM studies WHERE nct_id = '1238'")
    end
    
    it "format csv file, returns http success" do
      get :index, format: :csv, query: "SELECT nct_id, brief_title, created_at, updated_at FROM studies WHERE nct_id='1238'"
      expect(response).to have_http_status(:success)
    end
  end

end
