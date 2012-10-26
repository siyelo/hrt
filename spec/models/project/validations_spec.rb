require File.dirname(__FILE__) + '/../../spec_helper'

describe Project, "Validations" do
  before :each do
    basic_setup_project
    @donor1    = FactoryGirl.create :organization
    FactoryGirl.create :user, organization: @donor1
    @donor2    = FactoryGirl.create :organization
    FactoryGirl.create :user, organization: @donor2
    @response1 = @donor1.latest_response
    @response2 = @donor2.latest_response
    @project1  = FactoryGirl.create(:project, data_response: @response1)
    @project2  = FactoryGirl.create(:project, data_response: @response2)
  end

  describe "#validation_errors" do
      it "returns no response errors" do
        @activity = FactoryGirl.create(:activity, data_response: @response, project: @project)
        @split    = FactoryGirl.create(:implementer_split, organization: @organization,
                            activity: @activity, budget: 10, spend: 10)
        FactoryGirl.create(:funding_flow, from: @organization,
                project: @project, project_from: @project, budget: 10, spend: 10)
        @project.validation_errors.should == []
      end
  end

  describe "#matches_in_flow_amount?" do
    context "activity amounts and in flow amounts are equal" do
      it "returns true" do
        @activity = FactoryGirl.create(:activity, data_response: @response, project: @project)
        @split    = FactoryGirl.create(:implementer_split, organization: @organization,
                            activity: @activity, budget: 1, spend: 9)
        @activity2 = FactoryGirl.create(:activity, data_response: @response, project: @project)
        @split    = FactoryGirl.create(:implementer_split, organization: @organization,
                            activity: @activity2, budget: 9, spend: 1)
        @activity.reload; @activity.save # refresh cached amounts
        @activity2.reload; @activity2.save # refresh cached amounts
        @project.reload
        @project.in_flows = [FactoryGirl.build(:funding_flow, from: @donor1, budget: 3, spend: 7),
                             FactoryGirl.build(:funding_flow, from: @donor2, budget: 7, spend: 3)]
        @project.save!
        @project.matches_in_flow_budget?.should be_true
        @project.matches_in_flow_spend?.should be_true
      end
    end

    context "activity amounts and in flow amounts are not equal" do
      it "returns false" do
        @activity = FactoryGirl.create(:activity, data_response: @response, project: @project)
        @split    = FactoryGirl.create(:implementer_split, organization: @organization,
                            activity: @activity, budget: 1, spend: 9)
        @activity.save # refresh cached amounts
        FactoryGirl.create(:funding_flow, from: @organization,
                project: @project, budget: 4, spend: 4)
        @project.reload
        @project.matches_in_flow_budget?.should be_false
        @project.matches_in_flow_spend?.should be_false
      end
    end
  end
end
