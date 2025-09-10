class UsersController < ApplicationController
  before_action :is_admin?, only: [:index, :show, :edit, :destroy]

  def index
    @joined_this_week = User.where(created_at: Time.current.beginning_of_week..Time.current.end_of_day).count
    @joined_this_month = User.where(created_at: Time.current.beginning_of_month..Time.current.end_of_day).count
    @user_count = User.count

    if params[:search].present?
      search_term = "%#{params[:search]}%"
      users_scope = User.where(
        "LOWER(first_name) LIKE :search OR LOWER(last_name) LIKE :search OR LOWER(email) LIKE :search OR LOWER(username) LIKE :search",
        search: search_term.downcase
      ).order(last_db_activity: :desc)
    else
      sort_by = params[:sort] || "created_at"
      asc_or_desc = params[:direction] == "asc" ? "asc" : "desc"
      users_scope = User.order(Arel.sql("#{sort_by} #{asc_or_desc} NULLS LAST"))
    end

    respond_to do |format|
      format.html { @users = users_scope.page(params[:page]).per(20) }
      format.csv do
        @users = users_scope
        send_data generate_csv(@users), filename: "users-#{Date.today}.csv"
      end
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

    def generate_csv(users)
      CSV.generate(headers: true) do |csv|
        csv << %w[ID Full_Name Email Username Joined]
        users.each do |user|
          csv << [user.id, user.full_name, user.email, user.username, user.created_at]
        end
      end
    end
end
