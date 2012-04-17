class DocumentsController < BaseController

  def index
    @documents = Document.visible_to_reporters.
      paginate(:page => params[:page], :per_page => 10,
               :order => 'LOWER(title) ASC')
  end

end
