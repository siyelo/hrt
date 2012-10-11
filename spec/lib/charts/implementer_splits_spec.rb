require 'spec_helper_lite'
require 'json'

require File.join(APP_ROOT, 'lib/charts/implementer_splits')

describe Charts::ImplementerSplits do
  let(:implementer_split1) { mock :implementer_split, name: 'Imp1', total_spend: 20, total_budget: 10 }
  let(:implementer_split2) { mock :implementer_split, name: 'Imp2', total_spend: 10, total_budget: 5 }
  let(:implementer_splits) { [implementer_split1, implementer_split2] }

  describe Charts::ImplementerSplits::Spend do
    it "defaults value method to :total_spend" do
      Charts::ImplementerSplits::Spend.value_method.should == :total_spend
    end

    it "expects those entities respond to name and total_spend" do
      implementer_split1.should_receive(:name).once
      implementer_split1.should_receive(:total_spend).once
      implementer_split2.should_receive(:name).once
      implementer_split2.should_receive(:total_spend).once
      pie = JSON.parse Charts::ImplementerSplits::Spend.new(implementer_splits).google_pie
      pie["values"].should == [["Imp1", 20.0], ["Imp2", 10.0]]
      pie["names"]["column1"].should == "Name"
      pie["names"]["column2"].should == "Amount"
    end
  end

  describe Charts::ImplementerSplits::Budget do
    it "defaults value method to :total_budget" do
      Charts::ImplementerSplits::Budget.value_method.should == :total_budget
    end

    it "expects those entities respond to name and total_budget" do
      implementer_split1.should_receive(:name).once
      implementer_split1.should_receive(:total_budget).once
      implementer_split2.should_receive(:name).once
      implementer_split2.should_receive(:total_budget).once
      pie = JSON.parse Charts::ImplementerSplits::Budget.new(implementer_splits).google_pie
      pie["values"].should == [["Imp1", 10.0], ["Imp2", 5.0]]
      pie["names"]["column1"].should == "Name"
      pie["names"]["column2"].should == "Amount"
    end
  end
end
