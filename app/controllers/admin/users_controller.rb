require 'set'
class Admin::UsersController < Admin::BaseController

  ### Constants
  SORTABLE_COLUMNS = ['email', 'full_name', 'organizations.name',
    'current_sign_in_at', 'roles_mask', 'invite_token']

  ### Inherited Resources
  inherit_resources

  ### Helpers
  helper_method :sort_column, :sort_direction

  def index
    scope  = User.joins(:organization).includes(:organization)
    if params[:query]
      scope  = scope.where(["UPPER(email) LIKE UPPER(:q) OR
        UPPER(full_name) LIKE UPPER(:q) OR
        UPPER(organizations.name) LIKE UPPER(:q)",
        {q: "%#{params[:query]}%"}])
    end
    @users = scope.paginate(page: params[:page], per_page: 100,
      order: "#{sort_column} #{sort_direction}")
  end

  def create
    @user = User.new(params[:user])
    if @user.save_and_invite(current_user)
      flash[:notice] = "User was successfully created"
      redirect_to admin_users_path
    else
      flash.now[:error] = "Sorry, we were unable to save that user"
      render action: 'new'
    end
  end

  def update
    # set roles to empty array if no role is assigned
    # otherwise, user model is saved, but user not notified for the error
    params[:user][:roles] = [] unless params[:user].has_key?(:roles)
    update! do |success, failure|
      success.html do
        flash[:notice] = "User was successfully updated"
        redirect_to edit_admin_user_url(resource)
      end
      failure.html do
        flash[:error] = "Oops, we couldn't save your changes"
        render action: 'edit'
      end
    end
  end

  def download_template
    report = Reports::Templates::Users.new('csv')
    send_report_file(report, 'users_template')
  end

  def create_from_file
    begin
      if params[:file].present?
        doc = FileParser.parse(params[:file].open.read, 'csv', {headers: true})
        if doc.headers.to_set == User::FILE_UPLOAD_COLUMNS.to_set
          saved, errors = User.create_from_file(doc)
          flash[:notice] = "Created #{saved} of #{saved + errors} users successfully"
        else
          flash[:error] = 'Wrong fields mapping. Please download the CSV template'
        end
      else
        flash[:error] = 'Please select a file to upload'
      end

      redirect_to admin_users_url
    rescue
      flash[:error] = "There was a problem with your file. Did you use the template and save it after making changes as a CSV file instead of an Excel file? Please post a problem at <a href='https://hrtapp.tenderapp.com/kb'>TenderApp</a> if you can't figure out what's wrong."
      redirect_to admin_users_url
    end
  end

  private
    def sort_column
      SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "email"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
