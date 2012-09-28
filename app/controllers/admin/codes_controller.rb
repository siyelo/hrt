require 'set'

class Admin::CodesController < Admin::BaseController

  ### Constants
  SORTABLE_COLUMNS = ['short_display', 'type', 'description']

  ### Inherited Resources
  inherit_resources

  ### Helpers
  helper_method :sort_column, :sort_direction

  def index
    params[:filter] = "Locations" unless params[:filter].present?
    scope = scoped_codes
    if params[:query].present? || params[:sort].present?
      @codes  = scope.where(["UPPER(short_display) LIKE UPPER(:q) OR
                                            UPPER(type) LIKE UPPER(:q) OR
                                            UPPER(description) LIKE UPPER(:q)",
                                            {q: "%#{params[:query]}%"}])
    else
      @codes = scope.order("id ASC").roots
    end
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

  private

    def sort_column
      SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "short_display"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

    def scoped_codes
      code_types = "Code::#{params[:filter].upcase}".constantize
      Code.with_types(code_types).with_last_version
    end
end
