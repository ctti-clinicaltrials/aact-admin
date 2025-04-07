class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_devise_permitted_parameters, if: :devise_controller?
  before_action :check_registration_disabled, only: [:new, :create]

  def edit
    user_sign_out if params['format'] == 'sign-out'
  end

  def user_sign_out
    sign_out(:user)
    redirect_to root_path
  end

  def create
    build_resource(sign_up_params)

    if resource.save
      sign_in(resource)
      UserMailer.send_event_notification('created', resource)
      flash[:notice] = 'Welcome! You have signed up successfully. You can now log into your account and access the database.'
      redirect_to root_path and return
    else
      clean_up_passwords(resource)
      respond_with resource
    end
  end

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

  def password
    redirect_to root_path if current_user.nil? 
  end

  protected

  def update_resource(resource, params) 
    if params[:password_confirmation].nil? && resource.errors.size == 0
      flash.now[:notice] = 'User succesfully updated!'
    end
    resource.update(params)
    if resource.errors.size == 0 && !params[:password_confirmation].nil?
      flash.now[:notice] = 'Password succesfully updated!'
    end
    UserMailer.send_event_notification('updated', resource) if resource.errors.size == 0
  end

  def configure_devise_permitted_parameters
    registration_params = [:first_name, :last_name, :email, :username, :password, :password_confirmation ]

    case params[:action]
    when 'update'
      devise_parameter_sanitizer.permit(:account_update) {
        |u| u.permit(registration_params << :current_password)
      }
    when 'password'
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

  private

  def check_registration_disabled
    if ENV['DISABLE_USER_REGISTRATION'] == 'true'
      flash[:alert] = 'User registration is currently disabled. Please try again later.'
      redirect_to root_path
    end
  end
end
