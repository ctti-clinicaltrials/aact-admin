require 'rails_helper'

RSpec.describe "Queries", type: :request do

  before do
    @user = User.create(email: 'UserEmail@email.com', first_name: 'Firstname', last_name: 'Lastname', username: 'user123', password: '1234567', db_activity: nil, last_db_activity: nil, admin: false)
    @user.confirm
    sign_in(@user)
    @user_admin = User.create(email: 'UserAdminEmail@email.com', first_name: 'FirstnameAdmin', last_name: 'LastnameAdmin', username: 'useradmin123', password: '1234567', db_activity: nil, last_db_activity: nil, admin: true)
    @user_admin.confirm
  end

  after do
    # delete all Background Jobs associated with each User before deleting each User
    @user.background_jobs.each do |job|
      job.destroy
    end  
    @user.destroy
    @user_admin.background_jobs.each do |job|
      job.destroy
    end  
    @user_admin.destroy
  end

  describe "GET /query" do
    it "renders the Query index page" do
      get query_path
      expect(response).to render_template(:index)
    end
    it "if less than 10 Background Jobs, creates a new Job and redirects to the Job's show page" do
      get query_path, query: "SELECT nct_id, brief_title, created_at, updated_at FROM studies WHERE nct_id='1238'"
      get query_path, query: "SELECT nct_id, brief_title, created_at, updated_at FROM studies WHERE nct_id='1238'"
      get query_path, query: "SELECT nct_id, brief_title, created_at, updated_at FROM studies WHERE nct_id='1238'"
      get query_path, query: "SELECT nct_id, brief_title, created_at, updated_at FROM studies WHERE nct_id='1238'"
      get query_path, query: "SELECT nct_id, brief_title, created_at, updated_at FROM studies WHERE nct_id='1238'"
      get query_path, query: "SELECT nct_id, brief_title, created_at, updated_at FROM studies WHERE nct_id='1238'"
      get query_path, query: "SELECT nct_id, brief_title, created_at, updated_at FROM studies WHERE nct_id='1238'"
      get query_path, query: "SELECT nct_id, brief_title, created_at, updated_at FROM studies WHERE nct_id='1238'"
      get query_path, query: "SELECT nct_id, brief_title, created_at, updated_at FROM studies WHERE nct_id='1238'"
      get query_path, query: "SELECT nct_id, brief_title, created_at, updated_at FROM studies WHERE nct_id='1238'"
      expect(response).to redirect_to background_job_path(id: BackgroundJob.last.id)
    end
    it "if more than 10 Background Jobs, does NOT create a new Job and redirects to the Background Jobs index page" do
      get query_path, query: "SELECT nct_id, brief_title, created_at, updated_at FROM studies WHERE nct_id='1238'"
      get query_path, query: "SELECT nct_id, brief_title, created_at, updated_at FROM studies WHERE nct_id='1238'"
      get query_path, query: "SELECT nct_id, brief_title, created_at, updated_at FROM studies WHERE nct_id='1238'"
      get query_path, query: "SELECT nct_id, brief_title, created_at, updated_at FROM studies WHERE nct_id='1238'"
      get query_path, query: "SELECT nct_id, brief_title, created_at, updated_at FROM studies WHERE nct_id='1238'"
      get query_path, query: "SELECT nct_id, brief_title, created_at, updated_at FROM studies WHERE nct_id='1238'"
      get query_path, query: "SELECT nct_id, brief_title, created_at, updated_at FROM studies WHERE nct_id='1238'"
      get query_path, query: "SELECT nct_id, brief_title, created_at, updated_at FROM studies WHERE nct_id='1238'"
      get query_path, query: "SELECT nct_id, brief_title, created_at, updated_at FROM studies WHERE nct_id='1238'"
      get query_path, query: "SELECT nct_id, brief_title, created_at, updated_at FROM studies WHERE nct_id='1238'"
      get query_path, query: "SELECT nct_id, brief_title, created_at, updated_at FROM studies WHERE nct_id='1238'"
      expect(response).to redirect_to background_jobs_path
    end
  end

end
