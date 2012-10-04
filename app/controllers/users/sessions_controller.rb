class Users::SessionsController < Devise::SessionsController

  # GET /users/sign_in
  def new
    redirect_to root_path
  end

  # POST /users/sign_in
  def create
    if resource = warden.authenticate(auth_options)
      sign_in(resource_name, resource)
      if current_user.organization.responses.count > 0 || current_user.sysadmin?
        set_flash_message(:notice, :signed_in) if is_navigational_format?
        path = session[:return_to].present? ? session[:return_to] : dashboard_path
        redirect_to path
      else
        sign_out(current_user)
        flash[:error] = "Your organization's responses have been removed by a System Administrator. Please <a href='http://hrtapp.tenderapp.com/discussion/new'> contact us </a> for further assistance"
        redirect_to root_path
      end
    else
      flash[:error] = 'Wrong Email or Password. '
      redirect_to root_path
    end

  end
end
