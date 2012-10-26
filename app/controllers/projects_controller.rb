require 'set'
require 'csv'

class ProjectsController < BaseController
  SORTABLE_COLUMNS = ['name']

  helper_method :sort_column, :sort_direction
  before_filter :prevent_browser_cache, only: [:index, :edit, :update] # firefox misbehaving
  before_filter :prevent_activity_manager, only: [:create, :update, :destroy]
  before_filter :check_response_status, only: [:create, :update, :destroy]

  def new
    @project = current_response.projects.new
  end

  def index
    scope = current_response.projects
    scope = scope.where(["UPPER(name) LIKE UPPER(:q)",
                                         {q: "%#{params[:query]}%"}]) if params[:query]
    @projects = scope.paginate(page: params[:page], per_page: 10,
                               order: "#{sort_column} #{sort_direction}",
                               include: :activities)
    @comment = Comment.new
    @comment.commentable = current_response
    @comments = Comment.on_all([current_response.id]).
                  order('created_at DESC').where('parent_id IS NULL')
    @project = Project.new(data_response: current_response)

    load_inline_forms
  end

  def edit
    @project = current_response.projects.find(params[:id])
    load_comment_resources(@project)
  end

  def create
    @project = Project.new(params[:project].merge(data_response: current_response))
    if @project.save
      respond_to do |format|
        format.html do
          flash[:notice] = "Project successfully created";
          redirect_to projects_path
        end
        format.js { render :save_success }
      end
    else
      respond_to do |format|
        format.html { render action: 'new' }
        format.js { render :save_failed }
      end
    end
  end

  def update
    @project = current_response.projects.find(params[:id])
    @project.activities.each { |a| a.name_will_change! } #force save
    if @project.update_attributes(params[:project])
      respond_to do |format|
        format.html {
          flash[:notice] = "Project successfully updated";
          redirect_to edit_project_url(@project)
        }
        format.js { render :save_success }
      end
    else
      respond_to do |format|
        format.html {load_comment_resources(@project); render action: 'edit'}
        format.js { render :save_failed }
      end
    end
  end

  def destroy
    @project = current_response.projects.find(params[:id])
    @project.destroy
    flash[:notice] = "Project was successfully destroyed"
    redirect_to projects_url
  end

  def import
    begin
      if params[:file].present?
        @i = Importer.new(current_response, params[:file].path)
        @projects = @i.projects
        @activities = @i.activities
        @other_costs = @i.other_costs
      else
        flash[:error] = 'Please select a file to upload'
        redirect_to projects_url
      end
    rescue CSV::MalformedCSVError, ArgumentError
      flash[:error] = "There was a problem with your file. Did you use the
                      template provided and save the file as either XLS or CSV?
                      Please post a problem at
                      <a href='https://hrtapp.tenderapp.com/kb'>TenderApp</a>
                      if you can't figure out what's wrong."
      redirect_to projects_url
    end
  end

  def download_template
    report = Reports::Templates::Projects.new('xls')
    send_report_file(report, 'import_template')
  end

  def export
    report = Reports::Detailed::ProjectsExport.new(current_response, 'xls')
    send_report_file(report, "all_activities")
  end

  def export_workplan
    # abt_associates_workplan
    org_workplan_filename = "#{current_response.organization.name.split.join('_').
       gsub(/\W+/, '').downcase.underscore}_workplan"

    report = Reports::Detailed::FunctionalWorkplan.new(current_response, nil, 'xls')
    send_report_file(report, org_workplan_filename)
  end

  protected
  def sort_column
    SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "name"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

  def begin_of_association_chain
    current_response
  end

  def load_inline_forms
    load_activity_new
    load_other_cost_new
  end
end
