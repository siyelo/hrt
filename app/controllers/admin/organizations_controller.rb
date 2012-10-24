require 'set'

class Admin::OrganizationsController < Admin::BaseController
  SORTABLE_COLUMNS  = ['name', 'raw_type', 'fosaid', 'created_at']

  ### Inherited Resources
  inherit_resources

  helper_method :sort_column, :sort_direction
  before_filter :load_organization, :only => [:edit, :update]
  before_filter :load_users, :only => [:edit, :update]

  def index
    scope = scope_organizations(params[:filter])
    if params[:query]
      scope = scope.where(["UPPER(organizations.name) LIKE UPPER(:q) OR
                            UPPER(organizations.raw_type) LIKE UPPER(:q) OR
                            UPPER(organizations.fosaid) LIKE UPPER(:q)",
                            {:q => "%#{params[:query]}%"}])
    end
    @organizations = scope.paginate(:page => params[:page], :per_page => 100,
                    :include => :users,
                    :order => "#{sort_column_query} #{sort_direction}, id ASC")
  end

  def show
    @target = Organization.find(params[:id], :include => [:projects,
      :activities, :users])
    @duplicate = Organization.find(params[:duplicate_id], :include => [:projects,
      :activities, :users])
    render :partial => 'organization_info'
  end

  def create
    create! do |success, failure|
      success.html do
        flash[:notice] = "Organization was successfully created"
        redirect_to edit_admin_organization_url(resource)
      end
    end
  end

  def update
    @organization.attributes = params[:organization]
    if @organization.save
      flash[:notice] = 'Organization was successfully updated'
      redirect_to edit_admin_organization_url(resource)
    else
      render :edit
    end
  end

  def destroy
    @organization = Organization.find(params[:id])

    if @organization.destroy
      flash[:notice] = "Organization was successfully destroyed."
      redirect_to admin_organizations_url
    else
      flash[:error] = "You cannot delete an organization with users or external reference data (i.e. funders/implementers)."
      redirect_to edit_admin_organization_url(@organization)
    end
  end

  def duplicate
    @all_organizations = Organization.ordered
  end

  def remove_duplicate
    if params[:duplicate_organization_id].blank? && params[:target_organization_id].blank?
      render_error("Duplicate or target organizations not selected.", duplicate_admin_organizations_path)
    elsif params[:duplicate_organization_id] == params[:target_organization_id]
      render_error("Same organizations for duplicate and target selected.", duplicate_admin_organizations_path)
    else
      duplicate = Organization.find(params[:duplicate_organization_id])
      target = Organization.find(params[:target_organization_id])

      if Organization.merge_organizations!(target, duplicate)
        render_notice("Organizations successfully merged.", duplicate_admin_organizations_path)
      else
        render_error("Organizations could not be merged. Did you remove all references to the duplicate first?", duplicate_admin_organizations_path)
      end
    end
  end

  def download_template
    report = Reports::Templates::Organizations.new([], 'csv')
    send_report_file(report, 'organization_template.csv')
  end

  def create_from_file
    begin
      if params[:file].present?
        doc = FileParser.parse(params[:file].open.read, 'csv', {:headers => true})
        if doc.headers.to_set == Organization::FILE_UPLOAD_COLUMNS.to_set
          saved, errors = Organization.create_from_file(doc)
          flash[:notice] = "Created #{saved} of #{saved + errors} organizations successfully"
        else
          flash[:error] = 'Wrong fields mapping. Please download the CSV template'
        end
      else
        flash[:error] = 'Please select a file to upload'
      end

      redirect_to admin_organizations_url
    rescue
      flash[:error] = "There was a problem with your file. Did you use the template and save it after making changes as a CSV file instead of an Excel file? Please post a problem at <a href='https://hrtapp.tenderapp.com/kb'>TenderApp</a> if you can't figure out what's wrong."
      redirect_to admin_organizations_url
    end
  end

  private

    def load_organization
      @organization = Organization.find(params[:id])
    end

    def load_users
      @users = @organization.users
    end

    def render_error(message, path)
      respond_to do |format|
        format.html do
          flash[:error] = message
          redirect_to path
        end
        format.js do
          render :remove_duplicate_error, :locals => { message: message }
        end
      end
    end

    def render_notice(message, path)
      respond_to do |format|
        format.html do
          flash[:notice] = message
          redirect_to path
        end
        format.js do
          render :remove_duplicate_notice, :locals => { message: message }
        end
      end
    end

    def sort_column
      SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "name"
    end

    def sort_column_query
      col = "organizations.#{sort_column}"
      col = "UPPER(#{col})" unless col == "organizations.created_at"
      col
    end

    def sort_direction
      direction = sort_column == "created_at" ? "desc" : "asc"
      %w[asc desc].include?(params[:direction]) ? params[:direction] : direction
    end

    # show reporting orgs by default.
    def scope_organizations(filter)
      case filter
      when 'Non-Reporting'
        Organization.nonreporting
      when 'Reporting'
        Organization.reporting
      when 'All'
        Organization.sorted
      else
        Organization.reporting
      end
    end
end
