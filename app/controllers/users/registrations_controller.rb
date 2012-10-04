class Users::RegistrationsController < Devise::RegistrationsController

  # GET /users/sign_up
  def new
    redirect_to root_path
  end

  # PUT /users/sign_up
  def update
    params[:user][:password] = nil if params[:user][:password].blank?
    params[:user][:password_confirmation] = nil if params[:user][:password_confirmation].blank?

    if @user.update_attributes(params[:user])
      flash[:notice] = 'Profile was successfully updated'
      if params[:user][:password].present?
        redirect_to root_path
      else
        redirect_to dashboard_path
      end
    else
      flash.now[:error] = "Oops, we couldn't save your changes."
      render :action => 'edit'
    end
  end

end
