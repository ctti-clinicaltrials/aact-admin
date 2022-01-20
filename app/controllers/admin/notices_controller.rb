class Admin::NoticesController < ApplicationController
  before_action :set_notice, only: [:show, :edit, :update, :destroy]
  before_action :is_admin?
  def index
    @notices= Notice.order(created_at: :desc)
  end

  def new
    @notice= Notice.new
  end

  def create
    @notice = Notice.new(notice_params)
    @notice.user = current_user
    if @notice.save
      redirect_to admin_notice_path(@notice), notice: 'Notice was successfully created.'
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
      redirect_to admin_notice_path(@notice), notice: 'Notice was successfully updated.'
    else
      # alert_errors @notice
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
    params.require(:notice).permit(:body, :title, :user_id, :visible, :send_emails)
  end

end
