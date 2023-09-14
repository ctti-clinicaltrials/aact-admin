require 'rails_helper'

RSpec.describe DictionaryController, type: :controller do
  describe "GET #show" do
    it 'should test the show action' do
      raise Core::Verifier.connection_config.inspect
    end

    it 'should show the search path' do
      raise Core::Verifier.connection.execute("SHOW search_path").first['search_path']
    end

    it 'should show the table' do
      raise Core::Verifier.connection.execute("SELECT COUNT(*) FROM ctgov.verifiers").to_a.inspect
    end
  end
end
