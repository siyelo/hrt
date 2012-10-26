class Admin::ReportsController < Admin::BaseController

  def index
    @report = Reports::Reporters.new(current_response.data_request)
  end

  def reporters
    @report = Reports::Reporters.new(current_response.data_request, double_count)
    render_report
  end

  def locations
    @report = Reports::DistrictSplit.new(current_request, double_count)
    render_report
  end

  def funders
    @report = Reports::Funders.new(current_response.data_request, double_count)
    render_report
  end

  def district_workplan
    district = Location.find_by_name(params[:district])
    double_count = params[:double_count] == 'true' ? true : false
    if district
      report = Reports::Detailed::DistrictWorkplan.new(
        current_request, district, double_count, 'xls')
      dc_string = double_count ? '_with_double_counts' : '_without_double_counts'
      send_report_file(report,
        "#{district.name}_district_workplan#{dc_string}")
    else
      redirect_to locations_admin_reports_path
    end
  end

  private
  def double_count
    @double_count || params[:double_count] == 'true' ? true : false
  end

  def double_counts_suffix
    double_count ? "double_counts_included" : "double_counts_excluded"
  end

  def render_report
    respond_to do |format|
      format.html do
        render :partial => '/reports/shared/report_data', :layout => false
      end
      format.xls do
        send_file(@report.to_xls, "#{params[:action]}_#{double_counts_suffix}.xls", 'application/vnd.ms-excel')
      end
    end
  end
end
