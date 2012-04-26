class Reports::ResponsesController < BaseController
  before_filter :load_response_from_id

  def overview
    @report = Reports::Organization.new(@response)
    render 'report'
  end
end
