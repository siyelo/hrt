class DashboardController < ApplicationController

  ### Filters
  before_filter :require_user

  def index
    if current_request
      @dashboard = Dashboard.new(current_user, current_response, current_request, params)
      render @dashboard.template
    else
      render 'no_request'
    end
  end
end
