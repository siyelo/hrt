class Admin::Reports::DetailedController < Admin::BaseController
  include ReportsControllerHelpers

  ### Filters
  before_filter :find_report, :only => [:show, :edit, :update]

  def index
    @request    = current_request

    # Data collected for the first request (id 8) is not valid due to changes
    # in the data structure of the application.  Therefore dynamic reports have
    # been disabled to prevent potentially incorrect reports from being generated.
    render 'not_available' and return if @request.id == 8 && RAILS_ENV != 'test'

    @response   = current_response
    @reports    = @request.reports.all
    @report_map = @reports.map_to_hash{|r| {r.key => r}}
  end

  # returns the report csv, or the formatted csv
  def show
    if @report.csv.exists?
      url = @report.private_csv_url
    else
      url = admin_reports_detailed_index_path
      flash[:error] = "Report is not generated yet."
    end

    redirect_to url
  end

  def mark_implementer_splits
    file = params[:file]

    if file
      if valid_format?(file)
        if is_zip?(file)
          csv = Report.unzip_csv(file.path)
        else
          csv = file.open.read
        end
        ImplementerSplit.mark_double_counting(csv)
        flash[:notice] = 'Your file is being processed, please reload this page in a couple of minutes to see the results'
      else
        flash[:error] = 'Invalid file format. Please select .csv or .zip format.'
      end
    else
      flash[:error] = 'Please select a file to upload'
    end

    redirect_to admin_reports_detailed_index_url
  end

  def generate
    ### Commented out lines allow reports to be generated locally (increase the timeout first)
    # @report = Report.find_or_initialize_by_key_and_data_request_id(params[:id], current_request.id)
    # @report.generate_report
    # redirect_to @report.private_csv_url

    @report = Report.find_or_create_by_key_and_data_request_id(params[:id], current_request.id)
    @report.generate_report_for_download(current_user)
    flash[:notice] = "We are generating your report and will send you an email (at #{current_user.email}) when it is ready."
    redirect_to admin_reports_detailed_index_path
  end

  protected

  def is_zip?(file)
    File.extname(file.original_filename) == ".zip"
  end

  def valid_format?(file)
    ['.csv', '.zip'].include?(File.extname(file.original_filename))
  end

  def find_report
    @report = Report.find params[:id]
  end
end
