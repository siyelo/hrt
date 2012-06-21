class WorkplansController < ApplicationController
  before_filter :require_user
  before_filter :require_activity_manager

  def download
    if current_user.workplan.exists?
      redirect_to current_user.workplan_private_url
    else
      generate_workplan
      redirect_to :back
    end
  end

  def generate
    generate_workplan
    flash[:notice] = "We are generating your combined workplan and will send you an email (at #{current_user.email}) when it is ready."
    redirect_to :back
  end

  private
  def generate_workplan
    report = Reports::Detailed::CombinedWorkplan.new(current_response, current_user, 'xls')
    report.generate_workplan_for_download
  end
end
