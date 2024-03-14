require 'rails_helper'

RSpec.describe "Saved Queries", type: :request do
  before do
    @user = User.create(email: 'UserEmail@email.com', first_name: 'Firstname', last_name: 'Lastname', username: 'user123', password: '1234567', db_activity: nil, last_db_activity: nil, admin: false)
    @user.confirm
    sign_in(@user)
    @user2 = User.create(email: 'User2Email@email.com', first_name: 'Firstname', last_name: 'Lastname2', username: 'user12345', password: '1234567', db_activity: nil, last_db_activity: nil, admin: false)
    @user2.confirm
  end

  after do
    # delete all Queries associated with each User before deleting each User
    @user.saved_queries.each do |query|
      query.destroy
    end  
    @user.destroy
    @user2.saved_queries.each do |query|
      query.destroy
    end  
    @user2.destroy
  end  

  describe "GET /saved_queries" do
    it "renders the Saved Queries index page" do       
      saved_q = FactoryBot.create(:saved_query, user_id: @user.id)
      get saved_queries_path
      expect(response).to render_template(:index)
    end
  end

  describe "GET /saved_queries/:id" do
    it "renders the Saved Query show page" do
      saved_q = FactoryBot.create(:saved_query, user_id: @user.id)
      get saved_query_path(id: saved_q.id)
      expect(response).to render_template(:show)
    end
    it "renders the Not Found (404) page if the Saved Query ID is invalid" do
      saved_q = FactoryBot.create(:saved_query, user_id: @user.id)
      get saved_query_path(id: 5000) # an ID that doesn't exist
      expect(response).to render_template("layouts/application")
    end
    it "renders the Saved Query show page if the current logged-in User is NOT the User that created the Query and the Query is Public" do
      saved_q = FactoryBot.create(:saved_query, user_id: @user2.id, public: true)
      get saved_query_path(id: saved_q.id)
      expect(response).to render_template(:show)
    end
    it "renders the Not Found (404) page if the current logged-in User is NOT the User that created the Query and the Query is Not Public" do
      saved_q = FactoryBot.create(:saved_query, user_id: @user2.id)
      get saved_query_path(id: saved_q.id)
      expect(response).to render_template("layouts/application")
    end
  end  

  describe "GET /saved_queries/new" do
    it "renders the Saved Query new page" do
      get new_saved_query_path
      expect(response).to render_template(:new)
    end
  end

  describe "POST /saved_queries/ with valid data" do
    it "saves a new Saved Query and redirects to the show page if valid attributes" do      
      saved_q = FactoryBot.attributes_for(:saved_query)
      expect { post saved_queries_path, params: {saved_query: saved_q} }.to change(SavedQuery, :count)
      expect(response).to redirect_to saved_query_path(id: SavedQuery.last.id)
    end
  end
  
  describe "POST /saved_queries/ with invalid data" do
    it "does not save a new Saved Query and renders the new page if invalid attribute (blank title)" do
      saved_q = FactoryBot.attributes_for(:saved_query, title: '')
      expect { post saved_queries_path, params: {saved_query: saved_q} }.to_not change(SavedQuery, :count)
      expect(response).to render_template(:new)
    end
    it "does not save a new Saved Query and renders the new page if invalid attribute (blank description)" do
      saved_q = FactoryBot.attributes_for(:saved_query, description: '')
      expect { post saved_queries_path, params: {saved_query: saved_q} }.to_not change(SavedQuery, :count)
      expect(response).to render_template(:new)
    end
    it "does not save a new Saved Query and renders the new page if invalid attribute (blank sql)" do
      saved_q = FactoryBot.attributes_for(:saved_query, sql: '')
      expect { post saved_queries_path, params: {saved_query: saved_q} }.to_not change(SavedQuery, :count)
      expect(response).to render_template(:new)
    end
  end

  describe "GET /saved_queries/:id/edit" do
    it "renders the Saved Query edit page if the current logged-in User is the User that created the Query" do
      saved_q = FactoryBot.create(:saved_query, user_id: @user.id)
      get edit_saved_query_path(id: saved_q.id)
      expect(response).to render_template(:edit)
    end
    it "renders the Not Found (404) page if the current logged-in User is NOT the User that created the Query" do
      saved_q = FactoryBot.create(:saved_query, user_id: @user2.id)
      get edit_saved_query_path(id: saved_q.id)
      expect(response).to render_template("layouts/application")
    end
  end  

  describe "PUT /saved_queries/:id with valid data" do
    it "updates a Saved Query and redirects to the show page if valid attribute" do
      saved_q = FactoryBot.create(:saved_query, user_id: @user.id)
      put saved_query_path(id: saved_q.id), params: {saved_query: {title: 'Testing valid data.'}}
      saved_q.reload
      expect(saved_q.title).to eq('Testing valid data.')
      expect(response).to redirect_to saved_query_path
    end
  end

  describe "PUT /saved_queries/:id with invalid data" do
    it "does not update a Saved Query and renders the edit page if invalid attribute (blank title)" do
      saved_q = FactoryBot.create(:saved_query, user_id: @user.id)
      put saved_query_path(id: saved_q.id), params: { saved_query: {title: ''}}
      saved_q.reload
      expect(saved_q.title).to_not eq('')
      expect(response).to render_template(:edit)
    end
    it "does not update a Saved Query and renders the edit page if invalid attribute (blank description)" do
      saved_q = FactoryBot.create(:saved_query, user_id: @user.id)
      put saved_query_path(id: saved_q.id), params: {saved_query: {description: ''}}
      saved_q.reload
      expect(saved_q.description).to_not eq('')
      expect(response).to render_template(:edit)
    end
    it "does not update a Saved Query and renders the edit page if invalid attribute (blank sql)" do
      saved_q = FactoryBot.create(:saved_query, user_id: @user.id)
      put saved_query_path(id:saved_q.id), params: {saved_query: {sql: ''}}
      saved_q.reload
      expect(saved_q.sql).to_not eq('')
      expect(response).to render_template(:edit)
    end  
  end

  describe "PUT /saved_queries/:id by a User that is NOT the creator of the query" do
    it "does not update a Saved Query and renders the Not Found (404) page if the current logged-in User is NOT the User that created the Query" do
      saved_q = FactoryBot.create(:saved_query, user_id: @user2.id)
      put saved_query_path(id: saved_q.id), params: {saved_query: {title: 'Testing valid data.'}}
      saved_q.reload
      expect(saved_q.title).to_not eq('Testing valid data.')
      expect(response).to render_template("layouts/application")
    end
  end

  describe "DELETE /saved_queries/:id " do
    it "destroys a Saved Query and redirects to the index page if the current logged-in User is the User that created the Query" do
      saved_q = FactoryBot.create(:saved_query, user_id: @user.id)
      expect { delete saved_query_path(id: saved_q.id) }.to change(SavedQuery, :count)
      expect(response).to redirect_to saved_queries_path
    end
    it "does NOT destroy a Saved Query and renders the Not Found (404) page if the current logged-in User is NOT the User that created the Query" do
      saved_q = FactoryBot.create(:saved_query, user_id: @user2.id)
      expect { delete saved_query_path(id: saved_q.id) }.to_not change(SavedQuery, :count)
      expect(response).to render_template("layouts/application")
    end
  end      
end    