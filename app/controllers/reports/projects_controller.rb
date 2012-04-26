class Reports::ProjectsController < BaseController

  def show
    @project = @response.projects.find(params[:id])
    @report  = Reports::Project.new(@project)
    render 'report'
  end
end
