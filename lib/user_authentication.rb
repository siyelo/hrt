module UserAuthentication

  def require_user
    unless current_user
      store_location
      flash[:error] = "You must be logged in to access that page"
      redirect_to root_url
    end
  end

  def require_admin
    unless current_user && current_user.sysadmin?
      store_location
      flash[:error] = "You must be an administrator to access that page"
      redirect_to root_url
    end
  end

  def require_activity_manager
    unless current_user && current_user.activity_manager?
      store_location
      flash[:error] = "You must be an activity manager to access that page"
      redirect_to root_url
    end
  end

  def require_no_user
    if current_user
      flash[:error] = "You must be logged out to access requested page"
      redirect_to root_path
    end
  end

  def prevent_activity_manager
    if current_user.activity_manager? &&
      !(current_user.sysadmin? || (current_user.reporter? &&
                                   current_user.organization.data_responses.include?(current_response)))
      flash[:error] = "You do not have permission to edit this resource"
      redirect_to :back
    end
  end

  def store_location
    session[:return_to] = request.url
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def check_response_status
    if uneditable_response? && !current_user.sysadmin?
      flash[:error] = "Your entry has already been submitted. If you wish to further edit your entry, please contact a System Administrator"
      redirect_to :back
    end
  end

  protected

  def uneditable_response?
    current_response.state == "accepted" || current_response.state == "submitted"
  end
end
