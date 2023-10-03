class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_devise_permitted_parameters, if: :devise_controller?

  def edit
    user_sign_out if params['format'] == 'sign-out'
  end

  def user_sign_out
    sign_out(:user)
    redirect_to root_path
  end

  def create
    super
    if resource.errors.size == 0
      UserMailer.send_event_notification('created', resource)
      flash[:notice] = 'You will soon receive an email from AACT. When you verify your email, you will have acces to your database account.'
    end
  end

  # def update
  #   byebug
  #   if @user.update(user_params)
  #     redirect_to users_path, notice: "User successfuly updated."
  #   else
  #     flash.now.alert = @user.errors.full_messages[0]
  #     render :edit
  #   end
  # end

  def destroy
    current_user.remove
    if resource.errors.empty?
      UserMailer.send_event_notification('removed', resource)
      redirect_to root_path
    else
      flash[:notice] = "#{resource.errors.first.first} #{resource.errors.first.last}"
      redirect_to edit_user_registration_path resource
    end
  end

  protected

  def update_resource(resource, params)
    resource.update(params)
    UserMailer.send_event_notification('updated', resource) if resource.errors.size == 0
  end

  def configure_devise_permitted_parameters
    registration_params = [:first_name, :last_name, :email, :username, :password, :password_confirmation ]

    case params[:action]
    when 'update'
      devise_parameter_sanitizer.permit(:account_update) {
        |u| u.permit(registration_params << :current_password)
      }
    when 'create'
      devise_parameter_sanitizer.permit(:sign_up) {
        |u| u.permit(registration_params)
      }
    when 'delete'
      devise_parameter_sanitizer.permit(:delete) {
        |u| u.permit(registration_params)
      }
    end
  end

  # def user_params
  #   params.require(:user).permit(:first_name, :last_name, :email, :username, :password, :password_confirmation )
  # end

end
