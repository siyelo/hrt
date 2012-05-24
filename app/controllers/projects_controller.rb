require 'set'

class ProjectsController < BaseController
  SORTABLE_COLUMNS = ['name']

  helper_method :sort_column, :sort_direction
  before_filter :strip_commas_from_in_flows, :only => [:create, :update]
  before_filter :prevent_browser_cache, :only => [:index, :edit, :update] # firefox misbehaving
  before_filter :require_admin, :only => [:import_and_save]
  before_filter :prevent_activity_manager, :only => [:create, :update, :destroy]

  def new
    @project = @response.projects.new
  end

  def index
    scope = @response.projects.scoped({})
    scope = scope.scoped(:conditions => ["UPPER(name) LIKE UPPER(:q)",
                                         {:q => "%#{params[:query]}%"}]) if params[:query]
    @projects = scope.paginate(:page => params[:page], :per_page => 10,
                               :order => "#{sort_column} #{sort_direction}",
                               :include => :activities)
    @comment = Comment.new
    @comment.commentable = @response
    @comments = Comment.on_all([@response.id]).roots.paginate :per_page => 20,
                                                :page => params[:page],
                                                :order => 'created_at DESC'
    @project = Project.new(:data_response => @response)
    self.load_inline_forms
  end

  def edit
    @project = @response.projects.find(params[:id])
    load_comment_resources(@project)
  end

  def create
    @project = Project.new(params[:project].merge(:data_response => @response))
    if @project.save
      respond_to do |format|
        format.html do
          flash[:notice] = "Project successfully created";
          redirect_to projects_path
        end
        format.js   { js_redirect('success') }
      end
    else
      respond_to do |format|
        format.html { render :action => 'new' }
        format.js   { js_redirect('failed') }
      end
    end
  end

  def update
    @project = @response.projects.find(params[:id])
    if @project.update_attributes(params[:project])
      respond_to do |format|
        format.html {
          flash[:notice] = "Project successfully updated";
          redirect_to edit_project_url(@project)
        }
        format.js {js_redirect('success')}
      end
    else
      respond_to do |format|
        format.html {load_comment_resources(@project); render :action => 'edit'}
        format.js {js_redirect('failed')}
      end
    end
  end

  def destroy
    @project = @response.projects.find(params[:id])
    @project.destroy
    flash[:notice] = "Project was successfully destroyed"
    redirect_to projects_url
  end

  def import
    begin
      if params[:file].present?
        @i = Importer.new
        @i.import(@response, params[:file].path)
        @projects = @i.projects
        @activities = @i.activities
      else
        flash[:error] = 'Please select a file to upload'
        redirect_to projects_url
      end
    rescue FasterCSV::MalformedCSVError
      flash[:error] = "There was a problem with your file. Did you use the template provided and save the file as either XLS or CSV?
                       Please post a problem at <a href='https://hrtapp.tenderapp.com/kb'>TenderApp</a> if you can't figure out what's wrong."
      redirect_to projects_url
    end
  end

  def import_and_save
    begin
      if params[:file].present?
        file = params[:file].open.read
        @i = Importer.new
        @i.import_and_save(@response, file)
        flash[:notice] = 'Your file is being processed, please reload this page in a couple of minutes to see the results'
      else
        flash[:error] = 'Please select a file to upload'
      end
      redirect_to projects_url
    rescue FasterCSV::MalformedCSVError
      flash[:error] = "There was a problem with your file. Did you use the template provided and save the file as either XLS or CSV?
                       Please post a problem at <a href='https://hrtapp.tenderapp.com/kb'>TenderApp</a> if you can't figure out what's wrong."
      redirect_to projects_url
    end
  end

  def download_template
    report = Reports::Templates::Projects.new('xls')
    send_report_file(report, 'import_template')
  end

  def export
    report = Reports::ProjectsExport.new(current_response, 'xls')
    send_report_file(report, "all_activities")
  end

  def export_workplan
    # abt_associates_workplan
    org_workplan_filename = "#{@response.organization.name.split.join('_').
       gsub(/\W+/, '').downcase.underscore}_workplan"

    report = Reports::FunctionalWorkplan.new(@response, nil, 'xls')
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
      @response
    end

    #TODO: this should be handled in in model instead
    def strip_commas_from_in_flows
      if params[:project].present? && params[:project][:in_flows_attributes].present?
        in_flows = params[:project][:in_flows_attributes]
        in_flows.each_pair do |id, in_flow|
          [:budget, :spend].each do |field|
            in_flows[id][field] = convert_number_column_value(in_flows[id][field])
          end
        end
      end
    end

    def convert_number_column_value(value)
      if value == false
        0
      elsif value == true
        1
      elsif value.is_a?(String)
        if (value.blank?)
          nil
        else
          value.gsub(",", "")
        end
      else
        value
      end
    end

    def load_inline_forms
      self.load_activity_new
      self.load_other_cost_new
    end

    def js_redirect(status)
      render :json => {:status => status,
                       :html => render_to_string(:partial => 'projects/bulk_result',
                       :layout => false,
                       :locals => {:project => @project,
                                   :response => @response})}
    end
end
