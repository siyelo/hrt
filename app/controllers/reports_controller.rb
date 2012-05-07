class ReportsController < BaseController

  def index
    @report = Reports::Organization.new(@response)
  end

  def locations
    @current_response = current_response
    @report = Reports::OrganizationLocations.new(@current_response)
    render :partial => '/reports/shared/report_data', :layout => false
  end

  def inputs
    @current_response = current_response
    @report = Reports::OrganizationInputs.new(@current_response)
    render :partial => '/reports/shared/report_data', :layout => false
  end
end
