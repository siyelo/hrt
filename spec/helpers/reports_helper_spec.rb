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

    it "links to the activity when on the projects overview page" do
      params[:controller] = "reports/projects"
      a = Factory.build(:activity, :id => '1', :name => 'a1')
      helper.resource_link(a).should == link_to(a.name, reports_activity_path(a))
    end

    it "displays the name of the input" do
      params[:controller] = "reports/inputs"
      input = mock(:input, :id => '1', :name => 'blar')
      helper.resource_link(input).should == "blar"
    end

    it "displays 'no name' if the element doesnt respond to name" do
      params[:controller] = "reports/inputs"
      input = mock(:input, :id => '1', :name => nil)
      helper.resource_link(input).should == "no name"
    end

    it "displays the name of the location" do
      params[:controller] = "reports/locations"
      location = mock(:location, :id => '1', :name => 'foo')
      helper.resource_link(location).should == "foo"
    end
  end
end
