require 'rails_helper'

RSpec.describe BackgroundJobsController, type: :controller do
  before do
    @user = User.create(email: 'UserEmail@email.com', first_name: 'Firstname', last_name: 'Lastname', username: 'user123', password: '1234567', db_activity: nil, last_db_activity: nil, admin: false)
    # @user.confirm
    sign_in(@user)

    @user2 = User.create(email: 'User2Email2@email.com', first_name: 'Firstname2', last_name: 'Lastname2', username: 'user321', password: '1234567', db_activity: nil, last_db_activity: nil, admin: false)
    # @user2.confirm
  end

  after do
    @user&.destroy
    @user2&.destroy
  end

  describe "GET #index" do
    it "returns http success" do
      get :history
      expect(response).to have_http_status(:success)
    end
  end

  describe "DELETE #destroy" do
    context "when the current logged-in User created the Background Job" do
      it "redirects to background_jobs_path" do
        backgnd_job = FactoryBot.create(:background_job, user_id: @user.id)
        delete :destroy, params: { id: backgnd_job.id }
        expect(response).to redirect_to(background_jobs_path)
      end

      it "deletes the Background Job" do
        backgnd_job = FactoryBot.create(:background_job, user_id: @user.id)
        expect { delete :destroy, params: { id: backgnd_job.id } }.to change(BackgroundJob, :count).by(-1)
      end
    end

    context "when the current logged-in User did NOT create the Background Job" do
      it "returns http not found" do
        backgnd_job = FactoryBot.create(:background_job, user_id: @user2.id)
        delete :destroy, params: { id: backgnd_job.id }
        expect(response).to have_http_status(:not_found)
      end

      it "does not delete the Background Job" do
        backgnd_job = FactoryBot.create(:background_job, user_id: @user2.id)
        expect { delete :destroy, params: { id: backgnd_job.id } }.not_to change(BackgroundJob, :count)
      end
    end
  end

  describe "GET #admin_history" do
    it "returns http success" do
      get :admin_history
      expect(response).to have_http_status(:success)
    end
  end
end
