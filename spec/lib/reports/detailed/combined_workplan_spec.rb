require 'spec_helper'

describe Reports::Detailed::CombinedWorkplan do
  describe "Attachments" do
    before :each do
      @organization  = FactoryGirl.create(:organization, name: 'org1')
      @user          = FactoryGirl.create(:activity_manager,
                                      organization: @organization)
      @organization2 = FactoryGirl.create(:organization, name: 'org2')
      FactoryGirl.create :user, organization: @organization2
      @organization3 = FactoryGirl.create(:organization, name: 'org3')
      FactoryGirl.create :user, organization: @organization3
      @request       = FactoryGirl.create(:data_request, organization: @organization)
      @response2     = @organization2.latest_response
      @user.organizations << @organization2
      @user.organizations << @organization3
      @project       = FactoryGirl.create(:project, data_response: @response2,
                               in_flows: [FactoryGirl.create(:funding_flow, from: @organization3)])
      @activity      = FactoryGirl.create(:activity, data_response: @response2,
                               project: @project)
      split          = FactoryGirl.create(:implementer_split, activity: @activity,
                               budget: 100, spend: 200,
                               organization: @organization)
      @activity.save!
    end

    it "should save attachments" do
      @user.workplan.exists?.should be_false
      Reports::Detailed::CombinedWorkplan.new(@response2, @user, 'xls').generate_workplan_for_download
      @user.workplan.exists?.should be_true
    end
  end
end
