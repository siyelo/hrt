class OrganizationsController < BaseController

  before_filter :load_organization_details, :only => [:edit, :update]

  def index
    organizations = Organization.find(:all,
      :order => 'UPPER(name)', :limit => 100,
      :conditions => ["UPPER(organizations.name) LIKE UPPER(?)",
                      "%#{params[:term]}%"])

    respond_to do |format|
      format.json { render :json => organizations.map(&:name) }
    end
  end

  def edit
    @organization.valid? # trigger validation errors
  end

  def update
    if @organization.update_attributes(params[:organization])
      flash[:notice] = "Settings were successfully updated."
      redirect_to edit_organization_path(:current)
    else
      flash.now[:error] = "Oops, we couldn't save your changes."
      render :action => :edit
    end
  end

  def export
    if params[:type] == 'NGO'
      organizations = Organization.reporting.with_type("Donors").ordered + Organization.with_type("NGO").ordered
    elsif params[:type] == 'centers'
      organizations = Organization.reporting.with_type("District Hospital").ordered + Organization.with_type("Health Center").ordered
    else
      organizations = Organization.reporting.ordered
    end
    template = Organization.reporting.download_template(organizations)
    send_csv(template, 'organizations.csv')
  end

  private
    def load_organization_details
      @organization = @response.organization
      @activity_managers = @organization.managers.includes(:organization)
      @users = @organization.users.includes(:organization).order("full_name ASC")
    end
end

