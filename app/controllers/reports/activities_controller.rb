class Reports::ActivitiesController < BaseController
  before_filter :load_activity

  def show
    @report  = Reports::Activity.new(@activity)
  end

  def locations
    @report = Reports::ActivityLocations.new(@activity)
    render :partial => '/reports/shared/report_data', :layout => false
  end

  def inputs
    @report = Reports::ActivityInputs.new(@activity)
    render :partial => '/reports/shared/report_data', :layout => false
  end

  private

  def load_activity
    @activity = @response.activities.find(params[:id])
  end
end
