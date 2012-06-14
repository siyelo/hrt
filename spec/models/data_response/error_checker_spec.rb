require File.dirname(__FILE__) + '/../../spec_helper'

describe DataResponse::ErrorChecker do
  let(:response) { DataResponse.new }

  describe "#projects_have_valid_funding_sources?" do
    it "fails if a project doesn't have an in flow" do
      p = mock :project, :in_flows => [],
        :funding_sources_have_organizations_and_amounts? => true
      response.should_receive(:projects).and_return [p]
      response.projects_have_valid_funding_sources?.should == false
    end

    it "fails if an in flow has a 0 budget AND spend" do
      p = mock :project, :in_flows => [mock :in_flow],
        :funding_sources_have_organizations_and_amounts? => false
      response.should_receive(:projects).and_return [p]
      response.projects_have_valid_funding_sources?.should == false
    end
  end

  describe "#projects_without_budget_type" do
    before :each do
      p = mock :project, :budget_type => nil
      response.should_receive(:projects).once.and_return([p])
    end

    it "returns all projects without budget type" do
      response.projects_without_budget_type.size.should == 1
    end

    it "fails if there are projects without a budget type" do
      response.projects_have_budget_types?.should be_false
    end
  end

  describe "#activities_coded" do
    it "fails if there are no activities" do
      response.should_receive(:normal_activities).and_return []
      response.activities_coded?.should be_false
    end

    it "fails if there are uncoded activities" do
      response.should_receive(:normal_activities).and_return [mock :activity]
      response.should_receive(:uncoded_activities).and_return [mock :activity]
      response.activities_coded?.should be_false
    end

    it "fails if an activity is missing a coding split" do
      activity1 = mock :activity, :budget_classified? => false
      response.should_receive(:normal_activities).exactly(3).times.and_return [activity1]
      response.uncoded_activities.should have(1).item
      response.activities_coded?.should be_false
    end
  end

  describe "#other_costs_coded" do
    it "fails if there are no activities" do
      response.should_receive(:other_costs).and_return []
      response.other_costs_coded?.should be_false
    end

    it "fails if there are uncoded activities" do
      response.should_receive(:other_costs).and_return [mock :oc]
      response.should_receive(:uncoded_other_costs).and_return [mock :oc]
      response.other_costs_coded?.should be_false
    end

    it "fails if an ocost is missing a location split" do
      oc = mock :othercost, :location_budget_splits_valid? => false
      response.should_receive(:other_costs).exactly(3).times.and_return [oc]
      response.uncoded_other_costs.should have(1).item
      response.other_costs_coded?.should be_false
    end
  end

  it "is ready to submit if everything is entered" do
    response.should_receive(:projects_entered?).and_return true
    response.should_receive(:projects_have_budget_types?).and_return true
    response.should_receive(:projects_have_activities?).and_return true
    response.should_receive(:projects_have_valid_funding_sources?).and_return true
    response.should_receive(:projects_have_other_costs?).and_return true
    response.should_receive(:activities_coded?).and_return true
    response.should_receive(:other_costs_coded?).and_return true
    response.should_receive(:implementer_splits_entered?).and_return true
    response.ready_to_submit?.should be_true
  end
end
