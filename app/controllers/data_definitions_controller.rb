class DataDefinitionsController < ApplicationController
  def index
    @data_definitions = DataDefinition.all
  end
end
