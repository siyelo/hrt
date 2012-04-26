class Reports::ProjectsController < BaseController
  before_filter :load_response

  def overview
    @project = @response.projects.find(params[:id])
    @report  = Reports::Project.new(@project)
    render 'report'
  end
end
