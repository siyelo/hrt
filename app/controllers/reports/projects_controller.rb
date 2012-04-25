class Reports::ProjectsController < ApplicationController
  before_filter :load_response

  def overview
    @project = @response.projects.find(params[:id])
    @report  = Reports::Project.new(@project)
    # @report  = Reports::Project.new(@response)
    render 'report'
  end
end
