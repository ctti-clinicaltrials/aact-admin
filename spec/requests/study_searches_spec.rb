require 'rails_helper'

RSpec.describe "Study Searches", type: :request do

  describe "GET /study_searches" do
    it "renders the Study Searches index page" do       
      FactoryBot.create(:core_study_search)
      get study_searches_path
      expect(response).to render_template(:index)
    end
  end

  describe "GET /study_searches/new" do
    it "renders the Study Searches new page" do
      get new_study_search_path
      expect(response).to render_template(:new)
    end
  end  
 
  describe "POST /study_searches/ with valid data" do
    it "saves a new Study Searches and redirects to the index page if valid attributes" do      
      study_search = FactoryBot.attributes_for(:core_study_search)
      expect { post study_searches_path, core_study_search: study_search }.to change(Core::StudySearch, :count)
      expect(response).to redirect_to study_searches_path
    end
  end 

  describe "POST /study_searches/ with invalid data" do
    it "does not save a new Study Searh and renders the new page if invalid attribute (blank name)" do
      study_search = FactoryBot.attributes_for(:core_study_search, name: '')
      expect { post study_searches_path, core_study_search: study_search }.to_not change(Core::StudySearch, :count)
      expect(response).to render_template(:new)
    end

    it "does not save a new Study Searches and renders the new page if invalid attribute (blank grouping)" do
      study_search = FactoryBot.attributes_for(:core_study_search, grouping: '')
      expect { post study_searches_path, core_study_search: study_search }.to_not change(Core::StudySearch, :count)
      expect(response).to render_template(:new)
    end
  end

  describe "GET /study_searches/:id/edit" do
    it "renders the Study Search edit page" do
      study_search = FactoryBot.create(:core_study_search)
      get edit_study_searches_path(id: study_search.id)
      expect(response).to render_template(:edit)
    end
  end
end  