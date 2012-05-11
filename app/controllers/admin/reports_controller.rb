class Admin::ReportsController < Admin::BaseController
  def index
    @report = Reports::Reporters.new(current_response.data_request)
  end
end
