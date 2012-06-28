module Dashboard

  def self.new(user, current_response, current_request)
    if user.sysadmin?
      Sysadmin.new(user, current_request)
    elsif user.activity_manager?
      ActivityManager.new(user, current_response, current_request)
    else
      Reporter.new(user, current_response)
    end
  end
end
