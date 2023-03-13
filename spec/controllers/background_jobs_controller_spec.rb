require 'rails_helper'

RSpec.describe BackgroundJobsController, type: :controller do

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

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    it "returns http success" do
      backgnd_job = FactoryBot.create(:background_job, user_id: @user.id)
      get :show, id: backgnd_job.id
      expect(response).to have_http_status(:success)
    end
    it "returns http not found if the Background Job ID is invalid" do
      backgnd_job = FactoryBot.create(:background_job, user_id: @user.id)
      get :show, id: 5000 # an ID that doesn't exist
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET #destroy" do
    it "returns http found if the current logged-in User is the User that created the Query" do
      backgnd_job = FactoryBot.create(:background_job, user_id: @user.id)
      delete :destroy, id: backgnd_job.id
      expect(response).to have_http_status(:found)
    end
    it "returns http not found if the current logged-in User is NOT the User that created the Query" do
      backgnd_job = FactoryBot.create(:background_job, user_id: @user2.id)
      delete :destroy, id: backgnd_job.id
      expect(response).to have_http_status(:not_found)
    end
  end

end
