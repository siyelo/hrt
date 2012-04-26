module ActivityManagerPermissions
  def check_activity_manager_permissions(org)
    if cannot_edit_resource?(org)
      flash[:error] = "You do not have permission to edit this resource"
      return false
    end
    true
  end

  ## for any resource dependant on projects and activities
  def can_edit_resource?(org)
    return true if current_user.sysadmin?
    !current_user.activity_manager? ||
    (current_user.reporter? && current_user.organization.eql?(org))
  end

  def cannot_edit_resource?(org)
    !can_edit_resource?(org)
  end
end
