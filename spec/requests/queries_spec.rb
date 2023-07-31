require 'rails_helper'

RSpec.describe "Queries", type: :request do

  describe "GET /query with invalid SQL query" do
    #  Can't create a study because Public::Study is READONLY, need to write SQL explicitly
    before(:each) do
      Query::Base.connection.execute("INSERT INTO studies(nct_id, brief_title, created_at, updated_at) VALUES('1239','hello', '2018-10-31', '2018-12-25')")
    end
    
    after(:each) do
      Query::Base.connection.execute("DELETE FROM studies WHERE nct_id = '1239'")
    end

    xit "does not run an SQL query and renders the index page" do
      get query_path, query: "SELECT nct_id, brief_title, created_at, updated_at FROM WHERE nct_id='1239'"
      expect(response).to render_template('query/index.html.erb')
    end
  end
  
  describe "GET /query with valid SQL query" do
    #  Can't create a study because Public::Study is READONLY, need to write SQL explicitly
    before(:each) do
      Query::Base.connection.execute("INSERT INTO studies(nct_id, brief_title, created_at, updated_at) VALUES('1238','hello', '2018-10-31', '2018-12-25')")
    end
    
    after(:each) do
      Query::Base.connection.execute("DELETE FROM studies WHERE nct_id = '1238'")
    end

    it "runs an SQL query and renders the index page" do
      get query_path, query: "SELECT nct_id, brief_title, created_at, updated_at FROM studies WHERE nct_id='1238'"
      expect(response).to render_template('query/index.html.erb')
    end
  end

  describe "GET /query with valid SQL query and respond to format html" do
    #  Can't create a study because Public::Study is READONLY, need to write SQL explicitly
    before(:each) do
      Query::Base.connection.execute("INSERT INTO studies(nct_id, brief_title, created_at, updated_at) VALUES('1238','hello', '2018-10-31', '2018-12-25')")
    end
    
    after(:each) do
      Query::Base.connection.execute("DELETE FROM studies WHERE nct_id = '1238'")
    end

    it "runs an SQL query and renders the index html" do
      get query_path(format: :html, query:  "SELECT nct_id, brief_title, created_at, updated_at FROM studies WHERE nct_id='1238'")
      expect(response).to render_template('query/index.html.erb')
    end
  end

  describe "GET /query with valid SQL query and respond to format CSV" do
    #  Can't create a study because Public::Study is READONLY, need to write SQL explicitly
    before(:each) do
      Query::Base.connection.execute("INSERT INTO studies(nct_id, brief_title, created_at, updated_at) VALUES('1238','hello', '2018-10-31', '2018-12-25')")
    end
    
    after(:each) do
      Query::Base.connection.execute("DELETE FROM studies WHERE nct_id = '1238'")
    end

    it "runs an SQL query and gets the query path to generate csv file" do
      get query_path(format: :csv, query: "SELECT nct_id, brief_title, created_at, updated_at has_dmc FROM studies WHERE nct_id='1238'")
      expect(response.body).to match(/1238/)
      expect(response.body).to match(/hello/)
    end
  end

end
