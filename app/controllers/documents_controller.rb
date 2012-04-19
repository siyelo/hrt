class DocumentsController < BaseController

  before_filter :load_response

  def index
    @documents = Document.visible_to_reporters.
      paginate(:page => params[:page], :per_page => 10,
               :order => 'LOWER(title) ASC')
  end

end
