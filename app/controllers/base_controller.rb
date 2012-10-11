class BaseController < ApplicationController
  before_filter :require_user

  protected

    # activity/new endpoint
    def load_activity_new
      @activity = Activity.new(data_response_id: @response.id)
      @activity.project = @response.projects.find_by_id(params[:project_id]) if params[:project_id]
    end

    # other_cost/new endpoint
    def load_other_cost_new
      @other_cost = OtherCost.new(data_response_id: @response.id)
      @other_cost.project = @response.projects.find_by_id(params[:project_id]) if params[:project_id]
      # if you cant find an existing project with given params
      # then just leave it nil (i.e. it will be an "other cost without a project")
      @other_cost.data_response = @response
    end
end
