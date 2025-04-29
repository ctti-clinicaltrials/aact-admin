class UsersController < ApplicationController
  before_action :is_admin?, only: [:index, :show, :edit, :destroy]

  def index
    @joined_this_week = User.where(created_at: Time.current.beginning_of_week..Time.current.end_of_day).count
    @joined_this_month = User.where(created_at: Time.current.beginning_of_month..Time.current.end_of_day).count
  
    @queries_this_week = DbUserActivity
    .where(when_recorded: Time.zone.today.beginning_of_week(:sunday)..Time.zone.today)
    .sum(:event_count)
  

    @queries_this_month = DbUserActivity
      .where(when_recorded: Time.zone.now.beginning_of_month..Time.zone.now.end_of_month)
      .sum(:event_count)

    @user_count = User.count
  
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @users = User.where(
        "LOWER(first_name) LIKE :search OR LOWER(last_name) LIKE :search OR LOWER(email) LIKE :search OR LOWER(username) LIKE :search",
        search: search_term.downcase
      ).order(last_db_activity: :desc).page(params[:page]).per(20)
    else
      sort_by = params[:sort] || "last_db_activity"
      asc_or_desc = params[:direction] == "asc" ? "asc" : "desc"
      @users = User.order(Arel.sql("#{sort_by} #{asc_or_desc} NULLS LAST")).page(params[:page]).per(20)
    end
  
    respond_to do |format|
      format.html
      format.csv { send_data generate_csv(@users), filename: "users-#{Date.today}.csv" }
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
        csv << %w[ID Full_Name Email Username Confirmed DB_Activity Last_DB_Activity]
        users.each do |user|
          csv << [user.id, user.full_name, user.email, user.username, user.display_confirmed_at, user.db_activity, user.display_last_db_activity]
        end
      end
    end
end
