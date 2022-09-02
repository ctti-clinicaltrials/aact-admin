require 'rails_helper'

RSpec.describe "Data Definitions", type: :request do

    describe "GET /data_definitions" do
      it "renders the Data Definitions index page" do
        get data_definitions_path
        expect(response).to render_template(:index)
      end
    end

    describe "GET /data_definition" do
      it "renders the Data Definition show page" do
        data_def = FactoryBot.create(:data_definition)
        get data_definition_path(id: data_def.id)
        expect(response).to render_template(:show)
      end
      it "redirects to the Data Definitions index page if the Data Definition ID is invalid" do
        get data_definition_path(id: 5000) # an ID that doesn't exist
        expect(response).to redirect_to data_definitions_path
      end
    end

    describe "GET /data_definitions/new" do
      it "renders the Data Definitions new page" do
        get new_data_definition_path
        expect(response).to render_template(:new)
      end
    end

    describe "GET /data_definitions/:id/edit" do
      it "renders the Data Definitions edit page" do
        data_def = FactoryBot.create(:data_definition)
        get edit_data_definition_path(id: data_def.id)
        expect(response).to render_template(:edit)
      end
    end

    describe "POST /data_definitions/ with valid data" do
      it "saves a new Data Definition and redirects to the show page if valid attributes" do
        data_def_attributes = { data_definition: {db_section: 'Code the Dream', table_name: 'AACT', data_type: 'string', ctti_note: 'Testing valid data.'} }
        expect { post data_definitions_path, data_def_attributes }.to change(DataDefinition, :count)
        expect(response).to redirect_to data_definitions_path
      end
    end

    # describe "POST /data_definitions/ with invalid data" do
    #   it "does not save a new Data Definition or redirects if invalid db_section" do
    #     data_def_attributes = { data_definition: {db_section: '', table_name: 'AACT', data_type: 'integer', ctti_note: 'Date NLM made study available via their API'} }
    #     expect { post data_definitions_path, data_def_attributes }.to_not change(DataDefinition, :count)
    #     expect(response).to render_template(:new)
    #   end
    #   it "does not save a new Data Definition or redirects if invalid ctti_note" do
    #     data_def_attributes = { data_definition: {db_section: 'title', table_name: 'AACT', data_type: 'boolean', ctti_note: ''} }
    #     expect { post data_definitions_path, data_def_attributes }.to_not change(DataDefinition, :count)
    #     expect(response).to render_template(:new)
    #   end
    # end

    describe "PUT /data_definitions/ with valid data" do
      it "updates a Data Definition and redirects to the show page if valid attribute" do
        data_def = FactoryBot.create(:data_definition)
        put data_definition_path(data_def.id), data_definition: {ctti_note: 'Testing valid data.'}
        data_def.reload
        expect(data_def.ctti_note).to eq('Testing valid data.')
        expect(response).to redirect_to data_definitions_path
      end
    end

    # describe "PUT /data_definitions/ with invalid data" do
    #   it "does not update the Data Definition or redirects if invalid table_name" do
    #     data_def = FactoryBot.create(:data_definition)
    #     put data_definition_path(data_def.id), data_definition: {table_name: ''}
    #     data_def.reload
    #     expect(data_def.table_name).not_to eq('')
    #     expect(response).to render_template(:edit)
    #   end
    #   it "does not update the Data Definition or redirects if invalid data_type" do
    #     data_def = FactoryBot.create(:data_definition)
    #     put data_definition_path(data_def.id), data_definition: {data_type: ''}
    #     data_def.reload
    #     expect(data_def.data_type).not_to eq('')
    #     expect(response).to render_template(:edit)
    #   end
    # end

    describe "DELETE /data_definitions " do
      it "deletes a Data Definition from Data Definitions" do
        data_def = FactoryBot.create(:data_definition)
        expect { delete data_definition_path(data_def.id) }.to change(DataDefinition, :count)
        expect(response).to redirect_to data_definitions_path
      end
    end
end