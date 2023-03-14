require 'rails_helper'

RSpec.describe "Background Jobs", type: :request do

  before do
    @user = User.create(email: 'UserEmail@email.com', first_name: 'Firstname', last_name: 'Lastname', username: 'user123', password: '1234567', db_activity: nil, last_db_activity: nil, admin: false)
    @user.confirm
    sign_in(@user)
    @user2 = User.create(email: 'User2Email2@email.com', first_name: 'Firstname2', last_name: 'Lastname2', username: 'user321', password: '1234567', db_activity: nil, last_db_activity: nil, admin: false)
    @user2.confirm
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
  end

  describe "GET /background_jobs" do
    it "renders the Background Jobs index page" do       
      backgnd_job = FactoryBot.create(:background_job, user_id: @user.id)
      get background_jobs_path
      expect(response).to render_template(:index)
    end
  end

  describe "GET /background_jobs/:id" do
    it "renders the Background Job show page if the current logged-in User is the User that created the Background Job" do
      backgnd_job = FactoryBot.create(:background_job, user_id: @user.id)
      get background_job_path(id: backgnd_job.id)
      expect(response).to render_template(:show)
    end
    it "renders the Not Found (404) page if the Background Job ID is invalid" do
      backgnd_job = FactoryBot.create(:background_job, user_id: @user.id)
      get background_job_path(id: 5000) # an ID that doesn't exist
      expect(response).to render_template("layouts/application")
    end
    it "renders the Background Job show page if the current logged-in User is an Admin" do
      # create Admin User
      @user_admin = User.create(email: 'UserAdminEmail@email.com', first_name: 'FirstnameAdmin', last_name: 'LastnameAdmin', username: 'useradmin123', password: '1234567', db_activity: nil, last_db_activity: nil, admin: true)
      @user_admin.confirm
      sign_in(@user_admin)  
      backgnd_job = FactoryBot.create(:background_job, user_id: @user_admin.id)
      get background_job_path(id: backgnd_job.id)
      expect(response).to render_template(:show)
      # delete all Background Jobs associated with Admin User before deleting Admin User
      @user_admin.background_jobs.each do |job|
        job.destroy
      end  
      @user_admin.destroy
    end
    it "renders the Not Found (404) page if the current logged-in User is NOT the User that created the Background Job" do
      backgnd_job = FactoryBot.create(:background_job, user_id: @user2.id)
      get background_job_path(id: backgnd_job.id)
      expect(response).to render_template("layouts/application")
    end
  end

  describe "DELETE /background_jobs/:id " do
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
