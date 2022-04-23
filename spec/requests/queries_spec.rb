require 'rails_helper'

RSpec.describe "Queries", type: :request do

  describe "GET /query/submit" do
    it "renders the Query submit page" do
      get query_submit_path
      expect(response).to render_template(:submit)
    end
  end

  describe "POST /query/index with valid SQL query" do
    it "runs an SQL query and renders to the index page" do
      post query_index_path, query: 'SELECT nct_id, study_type, brief_title, enrollment, has_dmc, completion_date, updated_at FROM studies LIMIT 20'
      expect(response).to render_template(:index)
    end
  end

  describe "POST /query/index with invalid SQL query" do
    it "does not run an SQL query and renders the submit page" do
      post query_index_path, query: 'SELECT nct_id, study_type, brief_title, enrollment, has_dmc, completion_date, updated_at FROM LIMIT 20'
      expect(response).to render_template(:submit)
    end
  end

end
