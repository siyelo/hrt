class Reports::LocationsController < BaseController

  def index
    @current_response = current_response
    @report = Reports::Location.new(@current_response)

    respond_to do |format|
      format.js {
        render :layout => false }
    end
  end
end
