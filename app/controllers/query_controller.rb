class QueryController < ApplicationController
  def index
    if params[:query]
      begin
        @results = Query::Base.connection.execute(params[:query])
      # if there is an error in the SQL query, display the form again with the error message
      rescue ActiveRecord::StatementInvalid => e
        @error = [e.message]
      end
    end 
  end
end
