class Reports::ActivitiesController < ReportsBaseController
  def show
    @report  = Reports::Activity.new(load_activity)
  end

  def implementers
    show
    render_report
  end

  def locations
    @report = Reports::ActivityLocations.new(load_activity)
    render_report
  end

  def inputs
    @report = Reports::ActivityInputs.new(load_activity)
    render_report
  end

  private

  def load_activity
    @response.activities.find(params[:id])
  end
end
