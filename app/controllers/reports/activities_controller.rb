class Reports::ActivitiesController < BaseController

  def show
    @activity = @response.activities.find(params[:id])
    @report  = Reports::Activity.new(@activity)
    render 'report'
  end
end
