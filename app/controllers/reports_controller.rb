class ReportsController < BaseController

  def index
    @report = Reports::Organization.new(@response)

    respond_to do |format|
      format.html { render 'report' }
      format.js { render :layout => false }
    end
  end
end
