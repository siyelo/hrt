require 'json'
require File.dirname(__FILE__) + '/../spec_helper_lite'

$: << File.join(APP_ROOT, "app/charts")

require 'app/charts/implementer_splits'

describe Charts::ImplementerSplits do
  let(:implementer_split1) { mock :implementer_split, :organization_name => 'Imp1', :spend => 20, :budget => 10 }
  let(:implementer_split2) { mock :implementer_split, :organization_name => 'Imp2', :spend => 10, :budget => 5 }
  let(:implementer_splits) { [implementer_split1, implementer_split2] }

  describe Charts::ImplementerSplits::Spend do
    it "defaults value method to :spend" do
      Charts::ImplementerSplits::Spend.value_method.should == :spend
    end

    it "expects those entities respond to name and spend" do
      implementer_split1.should_receive(:organization_name).once
      implementer_split1.should_receive(:spend).once
      implementer_split2.should_receive(:organization_name).once
      implementer_split2.should_receive(:spend).once
      pie = JSON.parse Charts::ImplementerSplits::Spend.new(implementer_splits).google_pie
      pie["values"].should == [["Imp1", 20.0], ["Imp2", 10.0]]
      pie["names"]["column1"].should == "Name"
      pie["names"]["column2"].should == "Amount"
    end
  end

  describe Charts::ImplementerSplits::Budget do
    it "defaults value method to :budget" do
      Charts::ImplementerSplits::Budget.value_method.should == :budget
    end

    it "expects those entities respond to name and budget" do
      implementer_split1.should_receive(:organization_name).once
      implementer_split1.should_receive(:budget).once
      implementer_split2.should_receive(:organization_name).once
      implementer_split2.should_receive(:budget).once
      pie = JSON.parse Charts::ImplementerSplits::Budget.new(implementer_splits).google_pie
      pie["values"].should == [["Imp1", 10.0], ["Imp2", 5.0]]
      pie["names"]["column1"].should == "Name"
      pie["names"]["column2"].should == "Amount"
    end
  end
end
