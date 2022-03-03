class UsersController < ApplicationController
  before_action :is_admin?, only: [:index, :show, :edit, :destroy]

  def index
    @user_count = User.all.size
    @users = User.order(:last_name)
    respond_to do |format|
      format.html
      format.csv { render text: @users.to_csv }
      format.xls { render text: @users.to_csv(col_sep: "\t") }
    end
  end

  def edit
  end

  def show
    redirect_to :controller => 'user_password', :action => 'create'
  end

  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to admin_url, notice: 'User was removed.' }
      format.json { head :no_content }
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.fetch(:user, {})
      params.require(:user).permit(:utf8, :authenticity_token, :commit, :_method, :first_name, :last_name, :email, :username)
    end
end
