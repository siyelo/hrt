class ActivitiesController < OutlaysController
  SORTABLE_COLUMNS = ['projects.name', 'description', 'spend', 'budget']

  before_filter :prevent_browser_cache, only: [:edit, :update] # firefox misbehaving
  before_filter :check_response_status, only: [:create, :update, :destroy]

  def new
    self.load_activity_new
  end

  def edit
    @activity = @response.activities.find(params[:id])
    prepare_edit(@activity)
  end

  def create
    @activity = @response.activities.new(params[:activity])
    save_outlay(@activity)
  end

  def update
    @activity = @response.activities.find(params[:id])
    update_outlay(@activity)
  end

  def destroy
    activity = @response.activities.find(params[:id])
    activity.destroy
    flash[:notice] = 'Activity was successfully destroyed'
    redirect_to projects_url
  end

  private

  def success_flash(action)
    flash[:notice] = "Activity was successfully #{action}."
    if params[:activity][:project_id] == Activity::AUTOCREATE.to_s
      flash[:notice] +=
        "  <a href=#{edit_project_path(@activity.project)}>Click here</a>
         to enter the funding sources for the automatically created project."
    end
  end

  def sort_column
    SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "projects.name"
  end

  def confirm_activity_type
    @activity = Activity.find(params[:id])
    return redirect_to edit_other_cost_path(@activity) if @activity.class.eql? OtherCost
  end
end
