require 'spec_helper'

describe ReportsHelper do
  describe "#resource_link" do
    it "links to the projects when on the reports index page" do
      params[:controller] = "reports"
      project = Factory.build(:project, :id => '1', :name => 'proj1', :in_flows => [])
      helper.resource_link(project).should == link_to(project.name, reports_project_path(project))
    end

    it "links to the other cost when on the reports index page" do
      params[:controller] = "reports"
      other_cost = Factory.build(:other_cost, :id => '1', :name => 'oc1')
      helper.resource_link(other_cost).should == link_to(other_cost.name, reports_activity_path(other_cost))
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
