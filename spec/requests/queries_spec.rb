require 'rails_helper'

RSpec.describe "Queries", type: :request do

  describe "GET /query/index" do
    it "renders the Query index page" do
      get query_index_path
      expect(response).to render_template(:index)
    end
  end

  describe "POST /query/submit with valid SQL query" do
    it "sets an SQL query and renders to the submit page if SQL query is valid" do
      post query_submit_path, query: 'SELECT nct_id, study_type, completion_date FROM studies LIMIT 5'
      expect(response).to render_template(:submit)
    end
  end

end
