class Admin::ReportsController < Admin::BaseController

  def index
    @report = Reports::Reporters.new(current_response.data_request)
  end

  def reporters
    double_count = params[:double_count] == 'true' ? true : false
    @report = Reports::Reporters.new(current_response.data_request, double_count)
    render :partial => '/reports/shared/report_data', :layout => false
  end

  def locations
    double_count = params[:double_count] == 'true' ? true : false
    @report = Reports::DistrictSplit.new(current_request, double_count)
    render :partial => '/reports/shared/report_data', :layout => false
  end

  def funders
    @report = Reports::Funders.new(current_response.data_request)
    render :partial => '/reports/shared/report_data', :layout => false
  end

  def district_workplan
    district = Location.find_by_short_display(params[:district])
    if district
      report = Reports::Detailed::DistrictWorkplan.new(current_request, district, 'xls')
      send_report_file(report, "#{district.short_display}_district_workplan")
    else
      redirect_to locations_admin_reports_path
    end
  end
end
