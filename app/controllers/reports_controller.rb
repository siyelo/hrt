class ReportsController < BaseController

  def index
    @report = Reports::Organization.new(@response)
    render 'report'
  end
end
