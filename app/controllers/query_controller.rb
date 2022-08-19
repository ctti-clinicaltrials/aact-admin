class QueryController < ApplicationController
  require 'csv'

  def index
    if params[:query]
      begin
        @results = Query::Base.connection.execute(params[:query])
      # if there is an error in the SQL query, display the form again with the error message
      rescue ActiveRecord::StatementInvalid => e
        @error = [e.message]
      end
    end
    respond_to do |format|
      format.csv  do
        response.headers['Content-Type'] = 'text/csv'
        response.headers['Content-Disposition'] = "attachment; filename=query.csv"
        render template: "query/index.csv.erb"
      end
      # format.json  { render json: @results }
      format.html { render template: "query/index.html.erb" }
    end
  end
end
