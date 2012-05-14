require File.dirname(__FILE__) + '/../spec_helper_lite'
$: << File.join(APP_ROOT, "app/reports")
require 'app/reports/inputs'

describe Reports::Inputs do
  let(:resource) { mock :resource }
  let(:splits) { mock :splits }
  let(:root_splits) { mock :splits }
  let(:report) { Reports::Inputs.new(resource) }

  it "finds the location splits for an activity" do
    splits.should_receive(:roots).twice.and_return root_splits
    resource.should_receive(:coding_spend_cost_categorization).and_return splits
    report.splits(resource, :spend)
    resource.should_receive(:coding_budget_cost_categorization).and_return splits
    report.splits(resource, :budget)
  end
end

