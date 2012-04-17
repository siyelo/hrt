class ReportsController < BaseController
  def index
    @current_response = current_response
    @report = Reports::Organization.new(@current_response)
  end
end
