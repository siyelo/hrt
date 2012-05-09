module Dashboard

  def self.new(user, current_response, current_request, params)
    if user.sysadmin?
      Sysadmin.new(user, current_request, params)
    elsif user.activity_manager?
      ActivityManager.new(user, current_response, current_request, params)
    else
      Reporter.new(user, current_response, params)
    end
  end
end
