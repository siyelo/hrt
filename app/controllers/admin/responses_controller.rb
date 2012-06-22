# require 'app/charts/responses'

class Admin::ResponsesController < Admin::BaseController
  include ResponseStates

  AVAILABLE_FILTERS = ["Not Yet Started", "Started", "Submitted",
    "Rejected", "Accepted"]

  helper_method :sort_column, :sort_direction

  def index
    @pie = Charts::Responses::State.new(current_request).google_bar
    scope = scope_responses(params[:filter])
    scope = scope.joins(:organization).
                  where(["UPPER(organizations.name) LIKE UPPER(:q)",
                        {:q => "%#{params[:query]}%"}]) if params[:query]

    @responses = scope.paginate(:page => params[:page], :per_page => 100,
                                :joins => :organization,
                                :include => :organization,
                                :order => "UPPER(organizations.name), data_responses.id ASC")
  end

  def new
    @response = DataResponse.new
  end

  def create
    @response = DataResponse.new(params[:data_response])
    if @response.save
      flash[:notice] = "Response was successfully created"
      redirect_to admin_responses_path
    else
      flash.now[:error] = "Sorry, we were unable to save that response"
      render :action => 'new'
    end
  end

  def destroy
    @data_response = DataResponse.find(params[:id])

    @data_response.destroy_asynchronously
    flash[:notice] = "#{@data_response.title} scheduled for deletion"
    redirect_to admin_responses_path
  end

  def export
    @report = Report.find_or_create_by_key_and_data_request_id('export_response_status', current_request.id)
    @report.generate_report
    redirect_to @report.private_url
  end

  private

  # show reporting orgs by default.
  def scope_responses(filter)
    case filter
    when 'All'
      DataResponse.with_request(current_request)
    else
      if allowed_filter?(filter)
        DataResponse.with_request(current_request).with_state([name_to_state(filter)])
      else
        DataResponse.with_request current_request
      end
    end
  end

  def allowed_filter?(filter)
    AVAILABLE_FILTERS.include?(filter)
  end
end
