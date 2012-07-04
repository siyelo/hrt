class ReportsController < ReportsBaseController

  def index
    @report = Reports::Organization.new(current_response)
  end

  def projects
    index
    render_report
  end

  def locations
    @report = Reports::OrganizationLocations.new(current_response)
    render_report
  end

  def inputs
    @report = Reports::OrganizationInputs.new(current_response)
    render_report
  end

end
