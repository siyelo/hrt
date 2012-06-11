class Users::SessionsController < Devise::SessionsController

  # POST /resource/sign_in
  def create
    if resource = warden.authenticate(auth_options)
      set_flash_message(:notice, :signed_in) if is_navigational_format?
      sign_in(resource_name, resource)
      redirect_to dashboard_path
    else
      flash[:error] = 'Wrong Email or Password. '
      redirect_to root_path
    end

  end
end
