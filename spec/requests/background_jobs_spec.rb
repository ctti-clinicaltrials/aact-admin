require 'rails_helper'

RSpec.describe "Background Jobs", type: :request do

  before do
    @user = User.create(email: 'UserEmail@email.com', first_name: 'Firstname', last_name: 'Lastname', username: 'user123', password: '1234567', db_activity: nil, last_db_activity: nil, admin: false)
    @user.confirm
    sign_in(@user)
    @user2 = User.create(email: 'User2Email2@email.com', first_name: 'Firstname2', last_name: 'Lastname2', username: 'user321', password: '1234567', db_activity: nil, last_db_activity: nil, admin: false)
    @user2.confirm
    @user_admin = User.create(email: 'UserAdminEmail@email.com', first_name: 'FirstnameAdmin', last_name: 'LastnameAdmin', username: 'useradmin123', password: '1234567', db_activity: nil, last_db_activity: nil, admin: true)
    @user_admin.confirm
  end

  after do
    # delete all Background Jobs associated with each User before deleting each User
    @user.background_jobs.each do |job|
      job.destroy
    end  
    @user.destroy
    @user2.background_jobs.each do |job|
      job.destroy
    end  
    @user2.destroy
    @user_admin.background_jobs.each do |job|
      job.destroy
    end  
    @user_admin.destroy
  end

  describe "GET /background_jobs" do
    it "If User is NOT an Admin, it renders the Background Jobs index page with no 'User Name' column" do       
      backgnd_job = FactoryBot.create(:background_job, user_id: @user.id)
      get background_jobs_path
      expect(response).to render_template(:index)
      expect(response.body).not_to match(/User Name/)
    end
    it "If User is an Admin, it renders the Background Jobs index page with 'User Name' column" do       
      # sign in Admin User
      sign_in(@user_admin)
      backgnd_job = FactoryBot.create(:background_job, user_id: @user_admin.id)
      get background_jobs_path
      expect(response).to render_template(:index)
      expect(response.body).to match(/User Name/)
    end
    it "it renders the Background Jobs index page with 'Job ID', 'Created At', 'Job Status', and 'Results' columns" do       
      backgnd_job = FactoryBot.create(:background_job, user_id: @user.id)
      get background_jobs_path
      expect(response).to render_template(:index)
      expect(response.body).to match(/Job ID/)
      expect(response.body).to match(/Created At/)
      expect(response.body).to match(/Job Status/)
      expect(response.body).to match(/Results/)
    end
  end

  describe "GET /background_jobs/:id" do
    it "renders the Background Job show page and does not display the 'User Name' if the current logged-in User is NOT an admin and is the User that created the Background Job" do
      backgnd_job = FactoryBot.create(:background_job, user_id: @user.id)
      get background_job_path(id: backgnd_job.id)
      expect(response).to render_template(:show)
      expect(response.body).not_to match(/User Name/)
    end
    it "renders the Not Found (404) page if the Background Job ID is invalid" do
      backgnd_job = FactoryBot.create(:background_job, user_id: @user.id)
      get background_job_path(id: 5000) # an ID that doesn't exist
      expect(response).to render_template("layouts/application")
    end
    it "renders the Background Job show page and displays the 'User Name' if the current logged-in User is an Admin" do
      # sign in Admin User
      sign_in(@user_admin)  
      backgnd_job = FactoryBot.create(:background_job, user_id: @user_admin.id)
      get background_job_path(id: backgnd_job.id)
      expect(response).to render_template(:show)
      expect(response.body).to match(/User Name/)
    end
    it "renders the Not Found (404) page if the current logged-in User is NOT an Admin and NOT the User that created the Background Job" do
      backgnd_job = FactoryBot.create(:background_job, user_id: @user2.id)
      get background_job_path(id: backgnd_job.id)
      expect(response).to render_template("layouts/application")
    end
    it "renders the Background Job show page, does NOT display 'Delete' button, displays 'Completed At' and 'Download' URL if the Job status is 'complete' " do
      backgnd_job = FactoryBot.create(:background_job, user_id: @user.id, status: 'complete', completed_at: DateTime.now)
      get background_job_path(id: backgnd_job.id)
      expect(response).to render_template(:show)
      expect(response.body).not_to match(/Delete/)
      expect(response.body).to match(/Completed At/)
      expect(response.body).to match(/Download/)
    end
    it "renders the Background Job show page, displays 'Queued...', and does NOT display 'Completed At' and 'Results' download URL if the Job status is 'pending' " do
      backgnd_job = FactoryBot.create(:background_job, user_id: @user.id)
      get background_job_path(id: backgnd_job.id)
      expect(response).to render_template(:show)
      expect(response.body).to match(/Queued.../)
      expect(response.body).not_to match(/Completed At/)
      expect(response.body).not_to match(/Results/)
    end
    it "renders the Background Job show page and displays 'Delete' button if the current User is the User that created Job and Job status is NOT 'complete' and is NOT 'working' " do
      backgnd_job = FactoryBot.create(:background_job, user_id: @user.id)
      get background_job_path(id: backgnd_job.id)
      expect(response).to render_template(:show)
      expect(response.body).to match(/Delete/)
    end
    it "renders the Background Job show page and displays 'Delete' button if the current User is an Admin and Job status is NOT 'complete' and is NOT 'working' " do
      # sign in Admin User
      sign_in(@user_admin)
      backgnd_job = FactoryBot.create(:background_job, user_id: @user_admin.id)
      get background_job_path(id: backgnd_job.id)
      expect(response).to render_template(:show)
      expect(response.body).to match(/Delete/)
    end
    it "renders the Background Job show page, displays 'Working...', and does NOT display 'Delete' button if the Job status is 'working' " do
      backgnd_job = FactoryBot.create(:background_job, user_id: @user.id, status: 'working')
      get background_job_path(id: backgnd_job.id)
      expect(response).to render_template(:show)
      expect(response.body).to match(/Working.../)
      expect(response.body).not_to match(/Delete/)
    end  
    it "renders the Background Job show page, displays 'User Error Message', and does NOT display 'Delete' button if the Job status is 'error' " do
      backgnd_job = FactoryBot.create(:background_job, user_id: @user.id, status: 'error')
      get background_job_path(id: backgnd_job.id)
      expect(response).to render_template(:show)
      expect(response.body).to match(/User Error Message/)
      expect(response.body).not_to match(/Delete/)
    end  
  end

  describe "DELETE /background_jobs/:id " do
    it "destroys a Background Job and redirects to the index page if the User is an Admin" do
      # sign in Admin User
      sign_in(@user_admin)
      backgnd_job = FactoryBot.create(:background_job, user_id: @user_admin.id)
      expect { delete background_job_path(id: backgnd_job.id) }.to change(BackgroundJob, :count)
      expect(response).to redirect_to background_jobs_path
    end
    it "destroys a Background Job and redirects to the index page if the current logged-in User is the User that created the Background Job" do
      backgnd_job = FactoryBot.create(:background_job, user_id: @user.id)
      expect { delete background_job_path(id: backgnd_job.id) }.to change(BackgroundJob, :count)
      expect(response).to redirect_to background_jobs_path
    end
    it "does NOT destroy a Background Job and renders the Not Found (404) page if the current logged-in User is NOT the User that created the Background Job" do
      backgnd_job = FactoryBot.create(:background_job, user_id: @user2.id)
      expect { delete background_job_path(id: backgnd_job.id) }.to_not change(BackgroundJob, :count)
      expect(response).to render_template("layouts/application")
    end
  end 

end