class StaticPageController < ApplicationController
  layout 'promo_landing'

  def index
    if current_user
      redirect_to dashboard_path
    else
      @documents = Document.visible_to_public.latest_first.
                            paginate :per_page => 5, :page => params[:page]

      if request.xhr?
        render :partial => 'static_page/documents'
      else
        render :index
      end
    end
  end

  def about
  end
end

