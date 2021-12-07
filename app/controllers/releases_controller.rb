class ReleasesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :catch_not_found
  before_action :set_release, only: [:edit, :update, :show, :destroy]

  def index
    @releases = Release.all
  end

  def new
    @release = Release.new
  end

  def edit
  end

  def show
  end

  def create
    # create Method with Error Handling:
    # If @release.save return non-nil values, that means they succeeded,
    # and we can redirect back to the release page with a success message.
    # If they return nil, we have the else processing:
    # First collect the error and put it in the flash.now.alert
    # Then do the render to :new.
    @release = Release.new(release_params)
    if @release.save
      flash.notice = "The release record was created successfully."
      redirect_to @release
    else
      flash.now.alert = @release.errors.full_messages.to_sentence
      render :new
    end
  end

  def update
    # update Method with Error Processing
    # If @release.update return non-nil values, that means they succeeded,
    # and we can redirect back to the release page with a success message.
    # If they return nil, we have the else processing:
    # First collect the error and put it in the flash.now.alert
    # Then do the render to :edit.
    if @release.update(release_params)
      flash.notice = "The release record was updated successfully."
      redirect_to @release
    else
      flash.now.alert = @release.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    @release.destroy
    respond_to do |format|
      format.html { redirect_to releases_url, notice: 'The release record was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_release
      @release = Release.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def release_params
      params.require(:release).permit(:title, :subtitle, :released_on, :body)
    end

    def catch_not_found(e)
      Rails.logger.debug("We had a not found exception.")
      flash.alert = e.to_s
      redirect_to releases_path
    end
end
