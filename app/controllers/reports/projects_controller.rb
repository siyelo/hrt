class Reports::ProjectsController < BaseController

  def show
    @project = current_response.projects.find(params[:id])
    @report  = Reports::Project.new(@project)
    render 'report'
  end

  def locations
    @project = current_response.projects.find(params[:id])
    @report = Reports::ProjectLocations.new(@project)
    render :partial => '/reports/shared/report_data', :layout => false
  end

  def inputs
    @project = current_response.projects.find(params[:id])
    @report = Reports::ProjectInput.new(@project)
    render :partial => '/reports/shared/report_data', :layout => false
  end
end
