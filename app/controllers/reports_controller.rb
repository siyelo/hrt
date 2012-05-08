class ReportsController < BaseController

  def index
    @report = Reports::Organization.new(current_response)
  end

  def locations
    @report = Reports::OrganizationLocations.new(current_response)
    render :partial => '/reports/shared/report_data', :layout => false
  end

  def inputs
    @report = Reports::OrganizationInputs.new(current_response)
    render :partial => '/reports/shared/report_data', :layout => false
  end
end
