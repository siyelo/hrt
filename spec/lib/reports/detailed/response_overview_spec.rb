# encoding: utf-8
require 'spec_helper'

describe Reports::Detailed::ResponseOverview do

  def run_report
    content = Reports::Detailed::ResponseOverview.new(@response, :budget, 'xls').data
    FileParser.parse(content, 'xls')
  end

  context "simple reports" do
    before :each do
      basic_setup_response
      @response.state = 'accepted'
      @response.save
      in_flows = [FactoryGirl.build(:funding_flow, :from => @organization,
                                    :budget => 100)]
      @project = FactoryGirl.create :project, :data_response => @response,
        :name => 'project',
        :in_flows => in_flows
      @project.save!
      @root_code = FactoryGirl.create :code
      @code1 = FactoryGirl.create :code, :official_name => "root"
      @activity = FactoryGirl.create :activity, :project => @project,
        :data_response => @response, :description => "desc"
      @is = FactoryGirl.create :implementer_split, :activity => @activity, :organization => @organization, :budget => 100, :double_count => true
      @mtef = FactoryGirl.create :mtef_code, :short_display => "sub_prog_name"
      @nsp = FactoryGirl.create :nsp_code, :short_display => "Nsp_code"
      @cost_categorization = FactoryGirl.create :input_budget_split,
        :percentage => 100, :activity => @activity, :code => @code1
      @budget_purpose = FactoryGirl.create :budget_purpose, :percentage => 100,
        :activity => @activity, :code => @code1
      @location_budget_split = FactoryGirl.create :location_budget_split,
        :percentage => 100, :activity => @activity, :code => @code1

      #creating dummy tree
      @mtef.move_to_child_of(@root_code)
      @nsp.move_to_child_of(@mtef)
      @code1.move_to_child_of(@nsp)
      @activity.reload;@activity.save
    end

    it "should return a 1 funder, 1 implementer report" do
      @project.budget_type = 'on'
      @project.save
      table = run_report
      table[0]['Data Source'].should == @organization.name
      table[0]['Funding Source'].should == @organization.name
      table[0]['Implementer'].should == @is.organization.name
      table[0]['Project'].should == @project.name
      table[0]['On/Off Budget'].should == 'on'
      table[0]['Description of Project'].should == @project.description
      table[0]['Activity'].should == @activity.name
      table[0]['Description of Activity'].should == @activity.description
      table[0]['Targets'].should == nil
      table[0]['Input Split Total %'].should == 100.0
      table[0]['Input Split %'].should == 100.0
      table[0]['Input'].should == @cost_categorization.code.short_display
      table[0]['Purpose Split Total %'].should == 100.0
      table[0]['Purpose Split %'].should == 100.0
      table[0]['MTEF Code'].should == "sub_prog_name"
      table[0]['NSP Code'].should == "Nsp_code"
      table[0]['Location Split Total %'].should == 100.0
      table[0]['Location Split %'].should == 100.0
      table[0]['Name of District'].should == @activity.locations.map(&:short_display).join(",")
      table[0]['Total Amount ($)'].round(2).should == 100.00
      table[0]['Actual Double Count'].should_not == true
    end
  end
end
