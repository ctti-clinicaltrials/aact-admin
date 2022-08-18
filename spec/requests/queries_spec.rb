require 'rails_helper'

RSpec.describe "Queries", type: :request do

  describe "GET /query with valid SQL query" do
    it "runs an SQL query and renders the index page" do
      get query_path, query: 'SELECT nct_id, study_type, brief_title, enrollment, has_dmc, completion_date, updated_at FROM studies LIMIT 5'
      expect(response).to render_template(:index)
    end
  end

  describe "GET /query with invalid SQL query" do
    it "does not run an SQL query and renders the index page" do
      get query_path, query: 'SELECT nct_id, study_type, brief_title, enrollment, has_dmc, completion_date, updated_at FROM LIMIT 5'
      expect(response).to render_template(:index)
    end
  end

end
