class VerifiersController < ApplicationController
    rescue_from ActiveRecord::RecordNotFound, with: :catch_not_found
    before_action :set_verifier, only: [:show]
    
    def index
      @verifiers = Core::Verifier.all.order(id: :asc)
    end
  
    def show
    end
  
private
      def set_verifier
        @verifiers = Core::Verifier.find(params[:id])
      end
  
      def catch_not_found(e)
        Rails.logger.debug("We had a not found exception.")
        flash.alert = e.to_s
        redirect_to verifiers_path
      end
end
