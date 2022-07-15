class DataDefinitionsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :catch_not_found
 
  def index
    @data_definitions = DataDefinition.all
  end

  def new
    @data_definition = DataDefinition.new
  end
 
  def create
    @data_definition = DataDefinition.new(data_definition_params)
    if @data_definition.save
      flash.notice = "The Data Definition record was created successfully."
      redirect_to data_definitions_path
    else
      flash.now.alert = @data_definition.errors.full_messages.to_sentence
      render :new
    end
  end
  
  private
    # Only allow a list of trusted parameters through.
    def data_definition_params
      params.require(:data_definition)
        .permit(:db_section, :table_name, :column_name, :data_type, :source, :nlm_link)
    end

    def catch_not_found(e)
      Rails.logger.debug("We had a not found exception.")
      flash.alert = e.to_s
      redirect_to data_definitions_path
    end
end
