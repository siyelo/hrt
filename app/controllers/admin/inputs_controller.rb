class Admin::InputsController < Admin::BaseController

  ### Inherited Resources
  inherit_resources

  def index
    @inputs = Input.with_last_version.order("id ASC")

    if params[:query].present?
      @inputs = @inputs.where(["UPPER(name) LIKE UPPER(:q) OR
                                   UPPER(description) LIKE UPPER(:q)",
                              {q: "%#{params[:query]}%"}])
    end
  end

  def update
    update! do |success, failure|
      success.html do
        flash[:notice] = "Input was successfully updated"
        redirect_to edit_admin_input_url(resource)
      end
    end
  end

end
