class Admin::RequestsController < Admin::BaseController
  ### Inherited Resources
  inherit_resources
  defaults resource_class: DataRequest,
           collection_name: 'requests',
           instance_name: 'request'

  respond_to :html

  def index
    @requests = DataRequest.paginate per_page: 10, page: params[:page],
                                          order: 'created_at DESC'
  end

  def create
    @request = DataRequest.new(params[:data_request])
    if @request.save
      flash[:notice] = "Please wait a few moments for the request and the associated responses to be created."
      redirect_to admin_requests_url
    else
      render action: :new
    end
  end

  def update
    @request = DataRequest.find(params[:id])
    if @request.update_attributes(params[:data_request])
      flash[:notice] = "Request was successfully updated"
      redirect_to admin_requests_url
    else
      render action: :edit
    end
  end

  def destroy
    data_request = DataRequest.find(params[:id])
    data_request.destroy_and_clean_response_references
    flash[:notice] = "Please wait a few moments for the request and the associated responses to be deleted."
    redirect_to admin_requests_url
  end
end
