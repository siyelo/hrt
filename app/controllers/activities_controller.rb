class ActivitiesController < BaseController
  SORTABLE_COLUMNS = ['projects.name', 'description', 'spend', 'budget']

  helper_method :sort_column, :sort_direction
  before_filter :confirm_activity_type, :only => [:edit]
  before_filter :prevent_activity_manager, :only => [:create, :update, :destroy]
  before_filter :prevent_browser_cache, :only => [:edit, :update] # firefox misbehaving

  def new
    self.load_activity_new
  end

  def edit
    @activity = @response.activities.find(params[:id])
    warn_if_not_classified(@activity) unless current_user.sysadmin?
    prepare_classifications(@activity)
    load_comment_resources(@activity)
    load_validation_errors(@activity) if on_implementers_page?
    paginate_splits(@activity)
  end

  def create
    @activity = @response.activities.new(params[:activity])
    if @activity.save
      success_flash("created")
      html_redirect
    else
      paginate_splits(@activity)
      render :action => 'new'
    end
  end

  def update
    @activity = @response.activities.find(params[:id])
    if @activity.update_attributes(params[:activity])
        success_flash("updated")
        html_redirect
    else
      prepare_classifications(@activity)
      load_comment_resources(@activity)
      paginate_splits(@activity)
      render :action => 'edit'
    end
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
        flash[:notice] += "  <a href=#{edit_project_path(@activity.project)}>Click here</a>
                           to enter the funding sources for the automatically created project."
      end
    end

    def sort_column
      SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "projects.name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end

    def confirm_activity_type
      @activity = Activity.find(params[:id])
      return redirect_to edit_other_cost_path(@activity) if @activity.class.eql? OtherCost
    end

    def prepare_classifications(activity)
      # if we're viewing classification 'tabs'
      if ['locations', 'purposes', 'inputs'].include? params[:mode]
        load_klasses :mode
        @budget_coding_tree = CodingTree.new(activity, @budget_klass)
        @spend_coding_tree  = CodingTree.new(activity, @spend_klass)
        @budget_assignments = @budget_klass.with_activity(activity).all.
                                map_to_hash{ |b| {b.code_id => b} }
        @spend_assignments  = @spend_klass.with_activity(activity).all.
                                map_to_hash{ |b| {b.code_id => b} }

        # set default to 'all'
        params[:view] = 'all' if params[:view].blank?
      end
    end

    # run validations on the models independently of any save action
    # useful if you want to show (existing) errors without having to save the form first.
    def load_validation_errors(resource)
      resource.implementer_splits.find(:all, :include => :organization).each {|is| is.valid?}
      resource.valid?
    end

    def on_implementers_page?
      params[:mode].blank?
    end
end
