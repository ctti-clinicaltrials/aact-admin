require 'rails_helper'

RSpec.describe "Data Definitions", type: :request do
  before do
    @user = FactoryBot.create(:user, admin: true)
    # @user.confirm
    sign_in(@user)
  end

  after do
    @user&.destroy
  end

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
      it "saves a new Data Definition and redirects to the index page if valid attributes" do
        data_def = FactoryBot.attributes_for(:data_definition)
        expect { post data_definitions_path, params: {data_definition: data_def} }.to change(DataDefinition, :count)
        expect(response).to redirect_to data_definitions_path
      end
    end
    
    describe "POST /data_definitions/ with invalid data" do
      it "does not save a new Data Definition and renders the new page if invalid attribute (blank db_section)" do
        data_def = FactoryBot.attributes_for(:data_definition, db_section: '')
        expect { post data_definitions_path, params: {data_definition: data_def} }.to_not change(DataDefinition, :count)
        expect(response).to render_template(:new)
      end
      it "does not save a new Data Definition and renders the new page if invalid attribute (blank table_name)" do
        data_def = FactoryBot.attributes_for(:data_definition, table_name: '')
        expect { post data_definitions_path, params: {data_definition: data_def} }.to_not change(DataDefinition, :count)
        expect(response).to render_template(:new)
      end
      it "does not save a new Data Definition and renders the new page if invalid attribute (blank column_name)" do
        data_def = FactoryBot.attributes_for(:data_definition, column_name: '')
        expect { post data_definitions_path, params: {data_definition: data_def} }.to_not change(DataDefinition, :count)
        expect(response).to render_template(:new)
      end
      it "does not save a new Data Definition and renders the new page if invalid attribute (blank data_type)" do
        data_def = FactoryBot.attributes_for(:data_definition, data_type: '')
        expect { post data_definitions_path, params: {data_definition: data_def} }.to_not change(DataDefinition, :count)
        expect(response).to render_template(:new)
      end
      it "does not save a new Data Definition and renders the new page if invalid attribute (blank source)" do
        data_def = FactoryBot.attributes_for(:data_definition, source: '')
        expect { post data_definitions_path, params: {data_definition: data_def} }.to_not change(DataDefinition, :count)
        expect(response).to render_template(:new)
      end
    end

    describe "PUT /data_definitions/ with valid data" do
      it "updates a Data Definition and redirects to the index page if valid attribute" do
        data_def = FactoryBot.create(:data_definition)
        put data_definition_path(data_def.id), params: {data_definition: {ctti_note: 'Testing valid data.'}}
        data_def.reload
        expect(data_def.ctti_note).to eq('Testing valid data.')
        expect(response).to redirect_to data_definitions_path
      end
    end

    describe "PUT /data_definitions/ with invalid data" do
      it "does not update a Data Definition and renders the edit page if invalid attribute (blank db_section)" do
        data_def = FactoryBot.create(:data_definition)
        put data_definition_path(data_def.id), params: {data_definition: {db_section: ''}}
        data_def.reload
        expect(data_def.db_section).to_not eq('')
        expect(response).to render_template(:edit)
      end
      it "does not update a Data Definition and renders the edit page if invalid attribute (blank table_name)" do
        data_def = FactoryBot.create(:data_definition)
        put data_definition_path(data_def.id), params: {data_definition: {table_name: ''}}
        data_def.reload
        expect(data_def.table_name).to_not eq('')
        expect(response).to render_template(:edit)
      end
      it "does not update a Data Definition and renders the edit page if invalid attribute (blank column_name)" do
        data_def = FactoryBot.create(:data_definition)
        put data_definition_path(data_def.id), params:{data_definition: {column_name: ''}}
        data_def.reload
        expect(data_def.column_name).to_not eq('')
        expect(response).to render_template(:edit)
      end
      it "does not update a Data Definition and renders the edit page if invalid attribute (blank data_type)" do
        data_def = FactoryBot.create(:data_definition)
        put data_definition_path(data_def.id),  params:{data_definition: {data_type: ''}}
        data_def.reload
        expect(data_def.data_type).to_not eq('')
        expect(response).to render_template(:edit)
      end
      it "does not update a Data Definition and renders the edit page if invalid attribute (blank source)" do
        data_def = FactoryBot.create(:data_definition)
        put data_definition_path(data_def.id),  params:{data_definition: {source: ''}}
        data_def.reload
        expect(data_def.source).to_not eq('')
        expect(response).to render_template(:edit)
      end
    end

    describe "DELETE /data_definitions " do
      it "deletes a Data Definition from Data Definitions and redirects to the index page" do
        data_def = FactoryBot.create(:data_definition)
        expect { delete data_definition_path(data_def.id) }.to change(DataDefinition, :count)
        expect(response).to redirect_to data_definitions_path
      end
    end
end