class UsersController < ApplicationController
  before_filter :require_user
  before_filter :require_activity_manager

  def activity_manager_workplan
    report = Reports::FunctionalWorkplan.new(current_response,
                current_user.organizations, 'xls')
    send_report_file(report, 'combined_workplan')
  end
end
