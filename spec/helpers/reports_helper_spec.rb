require 'spec_helper'

describe ReportsHelper do
  describe "#resource_link" do
    it "links to the projects when on the reports index page" do
      params[:controller] = "reports"
      project = mock(:project, :id => '1', :name => 'proj1')
      helper.resource_link(project).should == "<a href=\"/reports/projects/1\">proj1</a>"
    end

    it "displays the name of the input" do
      params[:controller] = "reports/inputs"
      input = mock(:input, :id => '1', :name => 'blar')
      helper.resource_link(input).should == "blar"
    end

    it "displays the name of the location" do
      params[:controller] = "reports/locations"
      location = mock(:location, :id => '1', :name => 'foo')
      helper.resource_link(location).should == "foo"
    end
  end
end
