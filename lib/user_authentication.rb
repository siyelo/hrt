module UserAuthentication

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user ||= current_user_session && current_user_session.record
    session[:email] = @current_user.email if @current_user
    @current_user
  end

  def require_user
    unless current_user
      store_location
      flash[:error] = "You must be logged in to access this page"
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
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

end
