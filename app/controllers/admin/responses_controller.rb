class Admin::ResponsesController < Admin::BaseController
  include DataResponse::States

  SORTABLE_COLUMNS  = ['name']
  AVAILABLE_FILTERS = ["Reporting", "Not Yet Started", "Started", "Submitted",
    "Rejected", "Accepted", "Non-Reporting"]

  helper_method :sort_column, :sort_direction

  def index
    @pie = Charts::DataResponsePies::data_response_status_pie(current_user.current_request)
    scope = scope_organizations(params[:filter])
    scope = scope.scoped(
      :conditions => ["UPPER(organizations.name) LIKE UPPER(:q)",
                      {:q => "%#{params[:query]}%"}]) if params[:query]

    @organizations = scope.paginate(:page => params[:page], :per_page => 100,
      :order => "UPPER(organizations.#{sort_column}) #{sort_direction}, id ASC")
  end

  private
    def sort_column
      SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "name"
    end

    def sort_direction
      direction = sort_column == "created_at" ? "desc" : "asc"
      %w[asc desc].include?(params[:direction]) ? params[:direction] : direction
    end

    # show reporting orgs by default.
    def scope_organizations(filter)
      case filter
      when 'Non-Reporting'
        Organization.nonreporting
      when 'Reporting'
        Organization.reporting
      when 'All'
        Organization.sorted
      when 'Not Yet Started'
        Organization.reporting.responses_by_states(current_request, [name_to_state(filter)])
      else
        if allowed_filter?(filter)
          Organization.responses_by_states(current_request, [name_to_state(filter)])
        else
          Organization.reporting
        end
      end
    end

    def allowed_filter?(filter)
      AVAILABLE_FILTERS.include?(filter)
    end
end
