class Admin::ReportsController < Admin::BaseController
  def index
    @report = Reports::Reporters.new(current_response.data_request)
  end

  def locations
    @report = Reports::DistrictSplit.new(current_request)
    render :partial => '/reports/shared/report_data', :layout => false
  end

  def district_workplan
    district = Location.find(params[:id])
    if district
      workplan = Reports::DistrictWorkplan.new(current_request, district).to_xls
      send_xls(workplan, "#{district.short_display}_district_workplan.xls")
    else
      redirect_to locations_admin_reports_path
    end
  end
end
