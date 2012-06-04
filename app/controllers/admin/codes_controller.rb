require 'set'
class Admin::CodesController < Admin::BaseController

  ### Constants
  SORTABLE_COLUMNS = ['short_display', 'type', 'description']

  ### Inherited Resources
  inherit_resources

  ### Helpers
  helper_method :sort_column, :sort_direction

  def index
    scope  = Code.scoped({})
    scope  = scope.scoped(:conditions => ["UPPER(short_display) LIKE UPPER(:q) OR
                                          UPPER(type) LIKE UPPER(:q) OR
                                          UPPER(description) LIKE UPPER(:q)",
                          {:q => "%#{params[:query]}%"}]) if params[:query]
    @codes = scope.paginate(:page => params[:page], :per_page => 10,
                    :order => "#{sort_column} #{sort_direction}")
  end

  def update
    update! do |success, failure|
      success.html do
        flash[:notice] = "Code was successfully updated"
        redirect_to edit_admin_code_url(resource)
      end
    end
  end

  def download_template
    report = Reports::Templates::Codes.new('csv')
    send_report_file(report, 'codes_template')
  end

  def create_from_file
    begin
      if params[:file].present?
        doc = FileParser.parse(params[:file].open.read, 'csv', {:headers => true})
        if doc.headers.to_set == Code::FILE_UPLOAD_COLUMNS.to_set
          saved, errors = Code.create_from_file(doc)
          flash[:notice] = "Created #{saved} of #{saved + errors} codes successfully"
        else
          flash[:error] = 'Wrong fields mapping. Please download the CSV template'
        end
      else
        flash[:error] = 'Please select a file to upload'
      end

      redirect_to admin_codes_url
    rescue
      flash[:error] = "There was a problem with your file. Did you use the template and save it after making changes as a CSV file instead of an Excel file? Please post a problem at <a href='https://hrtapp.tenderapp.com/kb'>TenderApp</a> if you can't figure out what's wrong.."
      redirect_to admin_codes_url
    end
  end

  private

    def sort_column
      SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "short_display"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
