class Admin::LocationsController < Admin::BaseController

  ### Inherited Resources
  inherit_resources

  def index
    @locations = Location.with_last_version.order("name ASC")

    if params[:query].present?
      @locations = @locations.where(["UPPER(name) LIKE UPPER(:q)",
                              {q: "%#{params[:query]}%"}])
    end
  end

  def update
    update! do |success, failure|
      success.html do
        flash[:notice] = "Location was successfully updated"
        redirect_to edit_admin_location_url(resource)
      end
    end
  end
end
