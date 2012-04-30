require 'spec_helper'

describe ReportsHelper do
  describe "#resource_link" do
    it "links to the projects when on the reports index page" do
      params[:controller] = "reports"
      project = mock(:project, :id => '1')
      helper.resource_link(project.id).should == "/reports/projects/1"
    end
  end
end
