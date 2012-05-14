class Reports::ActivitiesController < BaseController
  def show
    @report  = Reports::Activity.new(load_activity)
  end

  def locations
    @report = Reports::ActivityLocations.new(load_activity)
    render :partial => '/reports/shared/report_data', :layout => false
  end

  def inputs
    @report = Reports::ActivityInputs.new(load_activity)
    render :partial => '/reports/shared/report_data', :layout => false
  end

  private

  def load_activity
    @response.activities.find(params[:id])
  end
end
