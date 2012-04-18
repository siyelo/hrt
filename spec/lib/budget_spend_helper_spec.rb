require 'budget_spend_helper'

describe BudgetSpendHelper do
  let(:activity) { mock("Activity").extend(BudgetSpendHelper) }
  let(:split) { mock "ImplementerSplit", :spend => 10, :budget => 10 }
  let(:splits) { [split, split] }

  [:total_spend, :total_budget].each do |method|
    describe "##{method}" do
      it "is zero when no splits" do
        activity.stub(:implementer_splits).and_return []
        activity.send(method).should == 0
      end

      it "adds up all splits" do
        activity.stub(:implementer_splits).and_return splits
        activity.send(method).should == 20
      end
    end
  end
end
