# Created app/controllers/errors_controller.rb for the not found (404)
# and internal server error (500) pages.
# Send an HTTP status of 404 or 500 according to error page being rendered.
class ErrorsController < ApplicationController
  def not_found
    render status: 404
  end

  def internal_server_error
    render status: 500
  end
end
