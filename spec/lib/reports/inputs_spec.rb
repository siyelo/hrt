require 'spec_helper'

describe Reports::Inputs do
  let(:resource) { mock :resource }
  let(:splits) { mock :splits }
  let(:root_splits) { mock :splits }
  let(:report) { Reports::Inputs.new(resource) }

  it "finds the location splits for an activity" do
    splits.should_receive(:roots).twice.and_return root_splits
    resource.should_receive(:input_spend_splits).and_return splits
    report.splits(resource, :spend)
    resource.should_receive(:input_budget_splits).and_return splits
    report.splits(resource, :budget)
  end
end

