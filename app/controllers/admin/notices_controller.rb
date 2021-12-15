class Admin::NoticesController < ApplicationController
  before_action :set_notice, only: [:show, :edit, :update, :destroy]

  def index
    @notices= Notice.all
  end

  def new
    @notice= Notice.new
  end

  def create
    @notice = Notice.new(notice_params)
    if @notice.save
      redirect_to @notice, notice: 'Notice was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def show
  end

  def update
    if @notice.update(notice_params)
      redirect_to @notice, notice: 'Notice was successfully updated.'
    else
      alert_errors @notice
      render :edit
    end
  end

  def destroy
    @notice.destroy
    redirect_to admin_notices_url, notice: 'Notice destroyed.'
  end

  private
  def set_notice
    @notice = Notice.find(params[:id])
  end

  def notice_params
    params.require(:notice).permit(:body, :title, :user_id, :visible)
  end

end
