class ResponsesController < BaseController
  before_filter :require_user
  before_filter :require_admin, :only => [:restart, :reject, :accept]
  before_filter :load_response_from_id

  def review
    ActiveRecord::Associations::Preloader.new(@response,
      [{:projects => :normal_activities}]).run
    @projects = @response.projects
  end

  def submit
    @projects = @response.projects.find(:all, :include => :normal_activities)
    if @response.ready_to_submit?
      @response.submit!
      flash[:notice] = "Successfully submitted. We will review your data and get back to you with any questions. Thank you."
      redirect_to review_response_url(@response)
    else
      @response.load_validation_errors
      render :review
    end
  end

  def reject
    @response.reject!
    if current_response.organization.users.map{ |u| u.email }.present?
      Notifier.response_rejected_notification(@response).deliver
    end
    flash[:notice] = "Response was successfully rejected"
    redirect_to projects_path
  end

  def accept
    @response.accept!
    if current_response.organization.users.map{ |u| u.email }.present?
      Notifier.response_accepted_notification(@response).deliver
    end
    flash[:notice] = "Response was successfully accepted"
    redirect_to projects_path
  end

  def restart
    @response.restart!
    if current_response.organization.users.map{ |u| u.email }.present?
      Notifier.response_restarted_notification(@response).deliver
    end
    flash[:notice] = "Response was successfully restarted"
    redirect_to projects_path
  end

  def approve_all_budgets
    case params[:type]
    when 'activities'
      ids = @response.projects.find(params[:project_id]).normal_activities
    when 'other_costs'
      ids = @response.projects.find(params[:project_id]).other_costs
    when 'other_costs_no_project'
      ids = @response.other_costs.without_a_project
    else
      ids = []
    end

    Activity.approve_all_budgets(ids.map(&:id), current_user.id)
    redirect_to projects_path
  end

  private
    # use this if your controller expects :id instead of :response_id
    def load_response_from_id
      find_response(params[:id])
    end
end
