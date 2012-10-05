class Admin::PurposesController < Admin::BaseController

  ### Inherited Resources
  inherit_resources

  def index
    @purposes = Purpose.order("id ASC")

    if params[:query].present?
      @purposes = @purposes.where(["UPPER(name) LIKE UPPER(:q) OR
                                   UPPER(description) LIKE UPPER(:q)",
                              {q: "%#{params[:query]}%"}])
    end
  end

  def update
    update! do |success, failure|
      success.html do
        flash[:notice] = "Purpose was successfully updated"
        redirect_to edit_admin_purpose_url(resource)
      end
    end
  end

end
