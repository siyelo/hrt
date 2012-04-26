class UsersController < ApplicationController
  before_filter :require_user
  before_filter :require_activity_manager

  def activity_manager_workplan
    workplan = Reports::ActivityManagerWorkplan.new(current_response, current_user.organizations)
    send_xls(workplan.to_xls,"combined_workplan.xls")
  end
end
