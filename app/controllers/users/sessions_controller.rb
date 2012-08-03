class Users::SessionsController < Devise::SessionsController

  def new
    redirect_to root_path
  end

  # POST /resource/sign_in
  def create
    if resource = warden.authenticate(auth_options)
      set_flash_message(:notice, :signed_in) if is_navigational_format?
      sign_in(resource_name, resource)
      path = session[:return_to].present? ? session[:return_to] : dashboard_path
      redirect_to path
    else
      flash[:error] = 'Wrong Email or Password. '
      redirect_to root_path
    end

  end
end
