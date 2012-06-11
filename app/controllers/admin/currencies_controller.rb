class Admin::CurrenciesController < Admin::BaseController

  ### Inherited Resources
  inherit_resources

  def index
    if params[:query]
      @currencies = Currency.sorted.
        where(['UPPER("currencies"."from") LIKE UPPER(:q) OR
                UPPER("currencies"."to") LIKE UPPER(:q)',
                {:q => "%#{params[:query]}%"}]).
        paginate(:page => params[:page], :per_page => 100)
    else
      @currencies = Currency.sorted.
        paginate(:page => params[:page], :per_page => 100)
    end
  end

  def create
    create! do |success, failure|
      success.html do
        flash[:notice] = "Currency was successfully created"
        redirect_to admin_currencies_url
      end
    end
  end

  def update
    update! do |success, failure|
      success.html do
        flash[:notice] = "Currency was successfully updated"
        redirect_to admin_currencies_url
      end
    end
  end

  def destroy
    destroy!(:notice => "Currency was successfully destroyed") { admin_currencies_url }
  end
end
