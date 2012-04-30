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
      oc = mock :othercost, :coding_budget_district_valid? => false
      response.should_receive(:other_costs).exactly(3).times.and_return [oc]
      response.uncoded_other_costs.should have(1).item
      response.other_costs_coded?.should be_false
    end
  end

  describe "#implementer_splits_entered_and_valid" do
    it "returns true if all activities have splits and the splits are valid" do
      response.should_receive(:activities_without_implementer_splits).and_return []
      response.should_receive(:invalid_implementer_splits).and_return []
      response.implementer_splits_entered_and_valid?.should be_true
    end

    it "returns false if any activity doesn't have splits or a split is invalid" do
      response.should_receive(:activities_without_implementer_splits).and_return [ mock :activity ]
      response.implementer_splits_entered_and_valid?.should be_false
    end
  end

  it "is ready to submit if everything is entered" do
    response.should_receive(:projects_entered?).and_return true
    response.should_receive(:projects_have_activities?).and_return true
    response.should_receive(:projects_have_valid_funding_sources?).and_return true
    response.should_receive(:projects_have_other_costs?).and_return true
    response.should_receive(:activities_coded?).and_return true
    response.should_receive(:other_costs_coded?).and_return true
    response.should_receive(:implementer_splits_entered_and_valid?).and_return true
    response.ready_to_submit?.should be_true
  end
end
