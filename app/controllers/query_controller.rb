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
        response.headers['Content-Disposition'] = 'attachment; filename=query.csv'
        # get headers from the keys of query results to generate first line of csv file
        headers = @results.first.map { |key,value| key }
        csv = CSV.generate_line headers
        # get rows from the values of the keys of query results to generate rest of lines of csv file
        @results.each do |result|
          rows = result.each.map { |key,value| value }  
          csv << CSV.generate_line(rows).html_safe
        end
        render plain: csv
      end
      format.html { render template: 'query/index.html.erb' }
    end
  end
end
