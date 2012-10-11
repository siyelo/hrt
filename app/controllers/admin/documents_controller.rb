class Admin::DocumentsController < Admin::BaseController

  ### Inherited Resources
  inherit_resources
  defaults resource_class: Document, collection_name: 'documents',
           instance_name: 'document'

  def index
    @documents = Document.paginate(page: params[:page], per_page: 10,
                                   order: 'LOWER(title) ASC')
  end

  def create
    create! do |success, failure|
      success.html do
        flash[:notice] = "File was successfully uploaded."
        redirect_to admin_documents_url
      end
    end
  end

  def update
    update! do |success, failure|
      success.html do
        flash[:notice] = "File was successfully updated."
        redirect_to admin_documents_url
      end
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html do
        flash[:notice] = "File was successfully deleted."
        redirect_to admin_documents_url
      end
    end
  end
end
