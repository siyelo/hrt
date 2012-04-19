class UsersController < ApplicationController
  before_filter :require_user
  before_filter :require_activity_manager, :only => [:activity_manager_workplan]

  # set the user's 'current response' based on the given Request id
  def set_request
    current_user.change_current_response!(params[:id])
    if current_user.current_response_is_latest?
      flash[:notice] = request_message(current_user.current_response.request)
    end
    redirect_back
  end

  def activity_manager_workplan
    workplan = Reports::ActivityManagerWorkplan.new(current_user.current_response, current_user.organizations)
    send_xls(workplan.to_xls,"combined_workplan.xls")
  end

  private

    def redirect_back
      referrer_uri = URI.parse(request.referrer)
      url_params = ActionController::Routing::Routes.
                    recognize_path(referrer_uri.path, :method => :get)

      if url_params[:response_id].present?
        data_response = DataResponse.find(url_params[:response_id])
        new_data_response = data_response.organization.responses.
                              find_by_data_request_id(params[:id])

        url_params[:response_id] = new_data_response.id
        redirect_to url_params
      else
        redirect_to :back
      end
    rescue ActionController::RedirectBackError
      redirect_to dashboard_path
    end
end
