class ReportsBaseController < BaseController
  def render_report
    respond_to do |format|
      format.html do
        render :partial => '/reports/shared/report_data', :layout => false
      end
      format.xls do
        send_file(@report.to_xls, "#{@report.name}-#{params[:action]}.xls", 'application/vnd.ms-excel')
      end
    end
  end
end
