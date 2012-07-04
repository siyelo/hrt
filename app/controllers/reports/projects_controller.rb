class Reports::ProjectsController < ReportsBaseController

  def show
    @report  = Reports::Project.new(load_project)
  end

  def activities
    show
    render_report
  end

  def locations
    @report = Reports::ProjectLocations.new(load_project)
    render_report
  end

  def inputs
    @report = Reports::ProjectInputs.new(load_project)
    render_report
  end

  private
  def load_project
    current_response.projects.find(params[:id])
  end
end
