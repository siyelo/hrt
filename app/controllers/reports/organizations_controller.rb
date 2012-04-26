class Reports::OrganizationsController < BaseController
  before_filter :load_response

  def overview
    @report = Reports::Organization.new(@response)
    render 'report'
  end
end
