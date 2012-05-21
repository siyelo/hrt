class Admin::ReportsController < Admin::BaseController
  def index
    @report = Reports::Reporters.new(current_response.data_request)
  end

  def locations
    @report = Reports::DistrictSplit.new(current_request)
    render :partial => '/reports/shared/report_data', :layout => false
  end

  def district_workplan
    district = Location.find_by_short_display(params[:district])
    if district
      report = Reports::DistrictWorkplan.new(current_request, district, 'xls')
      send_report_file(report, "#{district.short_display}_district_workplan")
    else
      redirect_to locations_admin_reports_path
    end
  end

  def funders
    @report = Reports::Funders.new(current_response.data_request)
    render :partial => '/reports/shared/report_data', :layout => false
  end
end
