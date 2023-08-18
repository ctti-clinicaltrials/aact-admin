require 'rails_helper'
require 'webmock/rspec'

RSpec.describe ClinicalTrialsApiV2 do
  BASE_URL_V2 = 'https://clinicaltrials.gov/api/v2/'

  describe '.studies' do
    it 'returns a list of studies' do
      stub_request(:get, "#{BASE_URL_V2}/studies").
        to_return(status: 200, body: '{"studies": [{"nct_id": "NCT123"}, {"nct_id": "NCT456"}]}', headers: {})

      response = ClinicalTrialsApiV2.studies
      expect(response).to be_a(Hash)
      expect(response['studies']).to be_an(Array)
      expect(response['studies'][0]['nct_id']).to eq('NCT123')
      expect(response['studies'][1]['nct_id']).to eq('NCT456')
    end
  end

  describe '.study' do
    it 'returns details of a single study' do
      nct_id = 'NCT789'
      stub_request(:get, "#{BASE_URL_V2}/studies/#{nct_id}").
        to_return(status: 200, body: '{"nct_id": "NCT789", "title": "Study Title"}', headers: {})

      response = ClinicalTrialsApiV2.study(nct_id)
      expect(response).to be_a(Hash)
      expect(response['nct_id']).to eq('NCT789')
      expect(response['title']).to eq('Study Title')
    end
  end

  describe '.metadata' do
    it 'returns data model fields' do
      stub_request(:get, "#{BASE_URL_V2}/studies/metadata").
        to_return(status: 200, body: '{"metadata": ["field1", "field2"]}', headers: {})

      response = ClinicalTrialsApiV2.metadata
      expect(response).to be_a(Hash)
      expect(response['metadata']).to be_an(Array)
      expect(response['metadata']).to eq(['field1', 'field2'])
    end
  end

  describe '.size' do
    it 'returns study size statistics' do
      stub_request(:get, "#{BASE_URL_V2}/stats/size").
        to_return(status: 200, body: '{"size": 100}', headers: {})

      response = ClinicalTrialsApiV2.size
      expect(response).to be_a(Hash)
      expect(response['size']).to eq(100)
    end
  end

  describe '.values' do
    it 'returns values statistics' do
      stub_request(:get, "#{BASE_URL_V2}/stats/fieldValues").
        to_return(status: 200, body: '{"values": ["value1", "value2"]}', headers: {})

      response = ClinicalTrialsApiV2.values
      expect(response).to be_a(Hash)
      expect(response['values']).to be_an(Array)
      expect(response['values']).to eq(['value1', 'value2'])
    end
  end

  describe '#fieldValues' do
    it 'returns field values statistics for a specific field' do
      field = 'condition'
      stub_request(:get, "#{BASE_URL_V2}/stats/fieldValues/#{field}").
        to_return(status: 200, body: '{"field": "condition", "values": [10, 20]}', headers: {})

      response = ClinicalTrialsApiV2.new.fieldValues(field)
      expect(response).to be_a(Hash)
      expect(response['field']).to eq(field)
      expect(response['values']).to eq([10, 20])
    end
  end

  describe '#listSizes' do
    it 'returns list sizes statistics' do
      stub_request(:get, "#{BASE_URL_V2}/stats/listSizes").
        to_return(status: 200, body: '{"listSizes": [10, 20]}', headers: {})

      response = ClinicalTrialsApiV2.new.listSizes
      expect(response).to be_a(Hash)
      expect(response['listSizes']).to eq([10, 20])
    end
  end

  describe '#listFields' do
    it 'returns list field size statistics for a specific field' do
      field = 'condition'
      stub_request(:get, "#{BASE_URL_V2}/stats/listSizes/#{field}").
        to_return(status: 200, body: '{"field": "condition", "size": 5}', headers: {})

      response = ClinicalTrialsApiV2.new.listFields(field)
      expect(response).to be_a(Hash)
      expect(response['field']).to eq(field)
      expect(response['size']).to eq(5)
    end
  end
end
