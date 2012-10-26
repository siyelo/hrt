require 'spec_helper'

describe Reports::Detailed::FunctionalWorkplan do
  describe "export projects and activities to xls" do
    it "should return xls with blank cells for repeated project & activity" do
      @organization  = FactoryGirl.create(:organization, name: 'org1')
      @user          = FactoryGirl.create(:activity_manager,
                                      organization: @organization)
      @organization2 = FactoryGirl.create(:organization, name: 'org2')
      FactoryGirl.create :user, organization: @organization2
      @organization3 = FactoryGirl.create(:organization, name: 'org3')
      FactoryGirl.create :user, organization: @organization3
      #Org without users or responses
      @organization4 = FactoryGirl.create(:organization, name: 'org4')

      @request       = FactoryGirl.create(:data_request,
                                          organization: @organization)
      @response      = @organization.latest_response
      @response2     = @organization2.latest_response
      @user.organizations << @organization2
      @user.organizations << @organization3

      @project       = FactoryGirl.create(:project, data_response: @response2,
                               in_flows: [FactoryGirl.create(
                                 :funding_flow, from: @organization3)])
      @activity      = FactoryGirl.create(:activity,
                                          data_response: @response2,
                                          project: @project)
      split          = FactoryGirl.create(:implementer_split,
                                          activity: @activity,
                               budget: 100, spend: 200,
                               organization: @organization)
      @ocost_no_project = FactoryGirl.create(:other_cost,
                                             data_response: @response2)
      @activity.reload
      @activity.save!

      @activity2     = FactoryGirl.create(:activity,
                                          data_response: @response2,
                               project: @project)
      split2         = FactoryGirl.create(:implementer_split,
                                          activity: @activity2,
                               budget: 200, spend: 200,
                               organization: @organization)
      split3         = FactoryGirl.create(:implementer_split,
                                          activity: @activity2,
                               budget: 200, spend: 200,
                               organization: @organization2)
      @activity2.reload
      @activity2.save!

      xls = Reports::Detailed::FunctionalWorkplan.new(@response,
             @user.organizations, 'xls').data
      rows = Spreadsheet.open(StringIO.new(xls)).worksheet(0)
      rows.row(0).should == ["Organization Name", "Project Name",
        "Project Description", "Funding Sources", "Activity Name",
        "Activity Description", "Type", "Activity Expenditure ($)",
        "Activity Budget ($)", "Implementers", "Targets", "Outputs",
        "Beneficiaries", "Districts worked in/National focus"]
      rows[1,0].should == @organization2.try(:name)
      rows[1,1].should == @project.try(:name)
      rows[1,2].should == @project.try(:description)
      rows[1,3].should == @project.in_flows.map{|ff| ff.from.name}.join(',')
      rows[1,4].should == ApplicationController.helpers.
                            friendly_name(@activity,50)
      rows[1,5].should == @activity.description
      rows[1,6].should == @activity.class.to_s.titleize
      rows[1,7].should == 200.00
      rows[1,8].should == 100.00
      rows[1,9].should == @activity.implementer_splits.
                            map{|is| is.organization.name}.join(', ')

      rows[2,0].should == nil
      rows[2,1].should == nil
      rows[2,2].should == nil
      rows[2,3].should == nil
      rows[2,4].should == ApplicationController.helpers.
                            friendly_name(@activity2,50)
      rows[2,5].should == @activity2.description
      rows[2,6].should == @activity2.class.to_s.titleize
      rows[2,7].should == 400.00
      rows[2,8].should == 400.00
      rows[2,9].should == @activity2.implementer_splits.
                            map{|is| is.organization.name}.join(', ')
      rows[3,4].should == ApplicationController.helpers.
                            friendly_name(@ocost_no_project,50)
      rows[4,0].should == @organization3.try(:name)
    end
  end
end
