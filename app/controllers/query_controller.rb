class QueryController < ApplicationController
  def index
  end

  def submit
    @results = Query::Base.connection.execute(params[:query])
  end
end
