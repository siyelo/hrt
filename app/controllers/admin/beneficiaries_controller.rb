class Admin::BeneficiariesController < Admin::BaseController

  ### Inherited Resources
  inherit_resources

  def index
    @beneficiaries = Beneficiary.order("id ASC")

    if params[:query].present?
      @beneficiaries = @beneficiaries.where(["UPPER(name) LIKE UPPER(:q)",
                              {q: "%#{params[:query]}%"}])
    end
  end

  def update
    update! do |success, failure|
      success.html do
        flash[:notice] = "Beneficiary was successfully updated"
        redirect_to edit_admin_beneficiary_url(resource)
      end
    end
  end

end
