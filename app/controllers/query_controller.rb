class QueryController < ApplicationController
  def index
  end

  def submit
    begin
      @results = Query::Base.connection.execute(params[:query])
    rescue PG::Error => e
      # if there is an error in the view, display the form again with the error message
      @error = e.message
    end
  end
end
