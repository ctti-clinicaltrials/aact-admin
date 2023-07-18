require 'rails_helper'

RSpec.describe "Study Statistics Comparison", type: :request do

  describe "GET /study_statistics_comparisons" do
    it "renders the Study Statistics Comparisons index page" do       
      study_stat_comp = FactoryBot.create(:core_study_statistics_comparison)
      get study_statistics_comparisons_path
      expect(response).to render_template(:index)
    end
  end
  
  describe "GET /study_statistics_comparisons/new" do
    it "renders the Study Statistics Comparison new page" do
      get new_study_statistics_comparison_path
      expect(response).to render_template(:new)
    end
  end  

  describe "POST /study_statistics_comparisons/ with valid data" do
    it "saves a new Study Statistics Comparison and redirects to the index page if valid attributes" do      
      study_stat_comp = FactoryBot.attributes_for(:core_study_statistics_comparison)
      expect { post study_statistics_comparisons_path, core_study_statistics_comparison: study_stat_comp }.to change(Core::StudyStatisticsComparison, :count)
      expect(response).to redirect_to study_statistics_comparisons_path
    end
  end  

  describe "POST /study_statistics_comparisons/ with invalid data" do
    it "does not save a new Study Statistics Comparison and renders the new page if invalid attribute (blank ctgov_selector)" do
      study_stat_comp = FactoryBot.attributes_for(:core_study_statistics_comparison, ctgov_selector: '')
      expect { post study_statistics_comparisons_path, core_study_statistics_comparison: study_stat_comp }.to_not change(Core::StudyStatisticsComparison, :count)
      expect(response).to render_template(:new)
    end
    it "does not save a new Study Statistics Comparison and renders the new page if invalid attribute (blank table)" do
      study_stat_comp = FactoryBot.attributes_for(:core_study_statistics_comparison, table: '')
      expect { post study_statistics_comparisons_path, core_study_statistics_comparison: study_stat_comp }.to_not change(Core::StudyStatisticsComparison, :count)
      expect(response).to render_template(:new)
    end
    it "does not save a new Study Statistics Comparison and renders the new page if invalid attribute (blank column)" do
      study_stat_comp = FactoryBot.attributes_for(:core_study_statistics_comparison, column: '')
      expect { post study_statistics_comparisons_path, core_study_statistics_comparison: study_stat_comp }.to_not change(Core::StudyStatisticsComparison, :count)
      expect(response).to render_template(:new)
    end
    it "does not save a new Study Statistics Comparison and renders the new page if invalid attribute (blank condition)" do
      study_stat_comp = FactoryBot.attributes_for(:core_study_statistics_comparison, condition: '')
      expect { post study_statistics_comparisons_path, core_study_statistics_comparison: study_stat_comp }.to_not change(Core::StudyStatisticsComparison, :count)
      expect(response).to render_template(:new)
    end
  end
  
  describe "GET /study_statistics_comparisons/:id/edit" do
    it "renders the Study Statistics Comparison edit page" do
      study_stat_comp = FactoryBot.create(:core_study_statistics_comparison)
      get edit_study_statistics_comparison_path(id: study_stat_comp.id)
      expect(response).to render_template(:edit)
    end
  end

  describe "PUT /study_statistics_comparisons/:id with valid data" do
    it "updates a Study Statistics Comparison and redirects to the index page if valid attribute" do
      study_stat_comp = FactoryBot.create(:core_study_statistics_comparison)
      put study_statistics_comparison_path(id: study_stat_comp.id), core_study_statistics_comparison: {ctgov_selector: 'Test CTGOV Selector'}
      study_stat_comp.reload
      expect(study_stat_comp.ctgov_selector).to eq('Test CTGOV Selector')
      expect(response).to redirect_to study_statistics_comparisons_path
    end
  end
  
  describe "PUT /study_statistics_comparisons/:id with invalid data" do
    it "does not update a Study Statistics Comparison and renders the edit page if invalid attribute (blank ctgov_selector)" do
      study_stat_comp = FactoryBot.create(:core_study_statistics_comparison)
      put study_statistics_comparison_path(id: study_stat_comp.id), core_study_statistics_comparison: {ctgov_selector: ''}
      study_stat_comp.reload
      expect(study_stat_comp.ctgov_selector).to_not eq('')
      expect(response).to render_template(:edit)
    end
    it "does not update a Study Statistics Comparison and renders the edit page if invalid attribute (blank table)" do
      study_stat_comp = FactoryBot.create(:core_study_statistics_comparison)
      put study_statistics_comparison_path(id: study_stat_comp.id), core_study_statistics_comparison: {table: ''}
      study_stat_comp.reload
      expect(study_stat_comp.table).to_not eq('')
      expect(response).to render_template(:edit)
    end
    it "does not update a Study Statistics Comparison and renders the edit page if invalid attribute (blank column)" do
      study_stat_comp = FactoryBot.create(:core_study_statistics_comparison)
      put study_statistics_comparison_path(id: study_stat_comp.id), core_study_statistics_comparison: {column: ''}
      study_stat_comp.reload
      expect(study_stat_comp.column).to_not eq('')
      expect(response).to render_template(:edit)
    end
    it "does not update a Study Statistics Comparison and renders the edit page if invalid attribute (blank condition)" do
      study_stat_comp = FactoryBot.create(:core_study_statistics_comparison)
      put study_statistics_comparison_path(id: study_stat_comp.id), core_study_statistics_comparison: {condition: ''}
      study_stat_comp.reload
      expect(study_stat_comp.condition).to_not eq('')
      expect(response).to render_template(:edit)
    end
  end
  
  describe "DELETE /study_statistics_comparisons/:id " do
    it "destroys a Study Statistics Comparison and redirects to the index page" do
      study_stat_comp = FactoryBot.create(:core_study_statistics_comparison)
      expect { delete study_statistics_comparison_path(id: study_stat_comp.id) }.to change(Core::StudyStatisticsComparison, :count)
      expect(response).to redirect_to study_statistics_comparisons_path
    end
  end  

end  