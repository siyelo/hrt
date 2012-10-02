class Admin::BeneficiariesController < Admin::BaseController

  def index
    @beneficiaries = Beneficiary.order("id ASC")

    if params[:query].present?
      @beneficiaries = @beneficiaries.where(["UPPER(name) LIKE UPPER(:q)",
                              {q: "%#{params[:query]}%"}])
    end
  end
end
