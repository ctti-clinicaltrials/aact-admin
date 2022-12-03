require 'rails_helper'

RSpec.describe "Saved Queries", type: :request do
  before do
    @user = User.create(email: 'UserEmail@email.com', first_name: 'Firstname', last_name: 'Lastname', username: 'user123', password: '1234567', db_activity: nil, last_db_activity: nil, admin: false)
    @user.confirm
    sign_in(@user)
    # @user2 = User.create(email: 'UserEmail2@email.com', first_name: 'Firstname', last_name: 'Lastname2', username: 'user12345', password: '1234567', db_activity: nil, last_db_activity: nil, admin: false)
    # @user2.confirm
  end

  after do
    # delete all queries associated with user before deleting the user
    @user.saved_queries.each do |query|
      query.destroy
    end  
    @user.destroy
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
      get saved_query_path(saved_q.id)
      expect(response).to render_template(:show)
    end
    it "redirects to the Saved Queries index page if the Saved Query ID is invalid" do
      get saved_query_path(id: 5000) # an ID that doesn't exist
      expect(response).to redirect_to saved_queries_path
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
      expect { post saved_queries_path, saved_query: saved_q }.to change(SavedQuery, :count)
      expect(response).to redirect_to saved_query_path(id: SavedQuery.last.id)
    end
  end
  
  # describe "POST /saved_queries/ with invalid data" do
  #   it "does not save a new Saved Query and renders the new page if invalid attribute (blank title)" do
  #     saved_q = FactoryBot.attributes_for(:saved_query, title: '')
  #     expect { post saved_queries_path, saved_query: saved_q }.to_not change(SavedQuery, :count)
  #     expect(response).to render_template(:new)
  #   end
  #   it "does not save a new Saved Query and renders the new page if invalid attribute (blank description)" do
  #     saved_q = FactoryBot.attributes_for(:saved_query, description: '')
  #     expect { post saved_queries_path, saved_query: saved_q }.to_not change(SavedQuery, :count)
  #     expect(response).to render_template(:new)
  #   end
  #   it "does not save a new Saved Query and renders the new page if invalid attribute (blank sql)" do
  #     saved_q = FactoryBot.attributes_for(:saved_query, sql: '')
  #     expect { post saved_queries_path, saved_query: saved_q }.to_not change(SavedQuery, :count)
  #     expect(response).to render_template(:new)
  #   end
  # end

  describe "GET /saved_queries/:id/edit" do
    it "renders the Saved Query edit page" do
      saved_q = FactoryBot.create(:saved_query, user_id: @user.id)
      get edit_saved_query_path(saved_q.id)
      expect(response).to render_template(:edit)
    end
  end  

  describe "PUT /saved_queries/:id with valid data" do
    it "updates a Saved Query and redirects to the show page if valid attribute" do
      saved_q = FactoryBot.create(:saved_query, user_id: @user.id)
      put saved_query_path(saved_q.id), saved_query: {title: 'Testing valid data.'}
      saved_q.reload
      expect(saved_q.title).to eq('Testing valid data.')
      expect(response).to redirect_to saved_query_path
    end
  end

  # describe "PUT /saved_queries/:id with invalid data" do
  #   it "does not update a Saved Query and renders the edit page if invalid attribute (blank title)" do
  #     saved_q = FactoryBot.create(:saved_query, user_id: @user.id)
  #     put saved_query_path(saved_q.id), saved_query: {title: ''}
  #     saved_q.reload
  #     expect(saved_q.title).to_not eq('')
  #     expect(response).to render_template(:edit)
  #   end
  #   it "does not update a Saved Query and renders the edit page if invalid attribute (blank description)" do
  #     saved_q = FactoryBot.create(:saved_query, user_id: @user.id)
  #     put saved_query_path(saved_q.id), saved_query: {description: ''}
  #     saved_q.reload
  #     expect(saved_q.description).to_not eq('')
  #     expect(response).to render_template(:edit)
  #   end
  #   it "does not update a Saved Query and renders the edit page if invalid attribute (blank sql)" do
  #     saved_q = FactoryBot.create(:saved_query, user_id: @user.id)
  #     put saved_query_path(saved_q.id), saved_query: {sql: ''}
  #     saved_q.reload
  #     expect(saved_q.sql).to_not eq('')
  #     expect(response).to render_template(:edit)
  #   end  
  # end

  describe "DELETE /saved_queries/:id " do
    it "destroys a Saved Query and redirects to the index page" do
      saved_q = FactoryBot.create(:saved_query, user_id: @user.id)
      expect { delete saved_query_path(saved_q.id) }.to change(SavedQuery, :count)
      expect(response).to redirect_to saved_queries_path
    end
  end  
    
end    