require 'rails_helper'

RSpec.describe "Queries", type: :request do

  before do
    @user = User.create(email: 'UserEmail@email.com', first_name: 'Firstname', last_name: 'Lastname', username: 'user123', password: '1234567', db_activity: nil, last_db_activity: nil, admin: false)
    # @user.confirm
    sign_in(@user)
  end
  
  describe "GET /query with invalid SQL query" do
    #  Can't create a study because Public::Study is READONLY, need to write SQL explicitly
    before(:each) do
      Query::Base.connection.execute("INSERT INTO studies(nct_id, brief_title, created_at, updated_at) VALUES('1239','hello', '2018-10-31', '2018-12-25')")
    end
    
    after(:each) do
      Query::Base.connection.execute("DELETE FROM studies WHERE nct_id = '1239'")
    end

    xit "does not run an SQL query and renders the index page" do
      get playground_path, query: "SELECT nct_id, brief_title, created_at, updated_at FROM WHERE nct_id='1239'"
      expect(response).to render_template('query/index.html.erb')
    end
  end

  after do
    # delete all Background Jobs associated with each User before deleting each User
    @user.background_jobs.each do |job|
      job.destroy
    end  
    @user.destroy
  end

  describe "GET /query" do
    it "renders the Query index page" do
      get playground_path
      expect(response).to render_template(:index)
    end
    it "if less than 10 Background Jobs (running + pending), creates a new Job and redirects to the Job's show page" do
      5.times do
        FactoryBot.create(:background_job, status: 'running', user_id: @user.id)
      end
      4.times do
        FactoryBot.create(:background_job, status: 'pending', user_id: @user.id)
      end  
      sql = { query: 'SELECT nct_id, study_type, brief_title, enrollment, has_dmc, completion_date, updated_at FROM studies LIMIT 10' }
      get playground_path(sql)
      expect(response).to redirect_to show_results_path(BackgroundJob.last.id)
    end
    it "if less than 10 Background Jobs (pending), creates a new Job and redirects to the Job's show page" do
      9.times do
        FactoryBot.create(:background_job, status: 'pending', user_id: @user.id)
      end  
      sql = { query: 'SELECT nct_id, study_type, brief_title, enrollment, has_dmc, completion_date, updated_at FROM studies LIMIT 10' }
      get playground_path(sql)
      expect(response).to redirect_to show_results_path(BackgroundJob.last.id)
    end
    it "if less than 10 Background Jobs (running), creates a new Job and redirects to the Job's show page" do
      9.times do
        FactoryBot.create(:background_job, status: 'running', user_id: @user.id)
      end  
      sql = { query: 'SELECT nct_id, study_type, brief_title, enrollment, has_dmc, completion_date, updated_at FROM studies LIMIT 10' }
      get playground_path(sql)
      expect(response).to redirect_to show_results_path(BackgroundJob.last.id)
    end
    it "if more than 10 Background Jobs (running + pending), does NOT create a new Job" do
      5.times do
        FactoryBot.create(:background_job, status: 'pending', user_id: @user.id)
        FactoryBot.create(:background_job, status: 'running', user_id: @user.id)
      end
      sql = { query: 'SELECT nct_id, study_type, brief_title, enrollment, has_dmc, completion_date, updated_at FROM studies LIMIT 11' }
      get playground_path(sql)
      expect(response).to render_template(:index)
    end
    it "if more than 10 Background Jobs (pending), does NOT create a new Job" do
      10.times do
        FactoryBot.create(:background_job, status: 'pending', user_id: @user.id)
      end
      sql = { query: 'SELECT nct_id, study_type, brief_title, enrollment, has_dmc, completion_date, updated_at FROM studies LIMIT 11' }
      get playground_path(sql)
      expect(response).to render_template(:index)
    end
    it "if more than 10 Background Jobs (running), does NOT create a new Job" do
      10.times do
        FactoryBot.create(:background_job, status: 'running', user_id: @user.id)
      end
      sql = { query: 'SELECT nct_id, study_type, brief_title, enrollment, has_dmc, completion_date, updated_at FROM studies LIMIT 11' }
      get playground_path(sql)
      expect(response).to render_template(:index)
    end
  end

end
