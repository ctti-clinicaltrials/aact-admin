require 'rails_helper'

RSpec.describe PlaygroundController, type: :controller do

  before do
    @user = User.create(email: 'UserEmail@email.com', first_name: 'Firstname', last_name: 'Lastname', username: 'user123', password: '1234567', db_activity: nil, last_db_activity: nil, admin: false)
    @user.confirm
    sign_in(@user)
    @user2 = User.create(email: 'User2Email2@email.com', first_name: 'Firstname2', last_name: 'Lastname2', username: 'user321', password: '1234567', db_activity: nil, last_db_activity: nil, admin: false)
    @user2.confirm
  end

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #index' do
  it 'redirects to show_results_path if query is provided and job can be created' do
    allow(controller).to receive(:current_user).and_return(@user)
    expect(@user.background_jobs).to receive(:where).and_return(@user.background_jobs)
    allow(@user.background_jobs).to receive(:count).and_return(5)

    get :index, params: { query: 'SELECT * FROM table' }

    expect(response).to redirect_to(show_results_path(assigns(:background_job).id))
    expect(flash[:notice]).to eq('The query was added to the queue successfully.')
  end

  it 'sets a flash alert and does not create a job if the queue is full' do
    allow(controller).to receive(:current_user).and_return(@user)
    expect(@user.background_jobs).to receive(:where).and_return(@user.background_jobs)
    allow(@user.background_jobs).to receive(:count).and_return(10)

    get :index, params: { query: 'SELECT * FROM table' }

    expect(response).to render_template(:index)
    expect(flash.now[:alert]).to eq('Cannot run query. You can only have a maximum of 10 queries in the queue.')
  end
end

  describe 'GET #show_results' do
    it 'renders the results page when the job exists and belongs to the user' do
      background_job = create(:background_job, url: nil, user: @user)
      allow(controller).to receive(:current_user).and_return(@user)

      get :show_results, params: { id: background_job.id }

      expect(response).to render_template(:show_results)
    end
  end

  after do
    @user&.destroy
    @user2&.destroy
  end
end
