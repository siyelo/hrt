require 'json'
require File.dirname(__FILE__) + '/../spec_helper_lite'

$: << File.join(APP_ROOT, "app/charts")

require 'app/charts/activities'

describe Charts::Activities do
  let(:activity1){ mock :activity, :name => 'p1', :total_spend => 20, :total_budget => 10 }
  let(:activity2){ mock :activity, :name => 'p2', :total_spend => 10, :total_budget => 5 }
  let(:activities) { [activity1, activity2] }

  describe Charts::Activities::Spend do
    it "defaults value method to :total_spend" do
      Charts::Activities::Spend.value_method.should == :total_spend
    end

    it "expects those entities respond to name and total_spend" do
      activity1.should_receive(:name).once
      activity1.should_receive(:total_spend).once
      activity2.should_receive(:name).once
      activity2.should_receive(:total_spend).once
      pie = JSON.parse Charts::Activities::Spend.new(activities).google_pie
      pie["values"].should == [["P1", 20.0], ["P2", 10.0]]
      pie["names"]["column1"].should == "Name"
      pie["names"]["column2"].should == "Amount"
    end
  end

  describe Charts::Activities::Budget do
    it "defaults value method to :total_budget" do
      Charts::Activities::Budget.value_method.should == :total_budget
    end

    it "expects those entities respond to name and total_budget" do
      activity1.should_receive(:name).once
      activity1.should_receive(:total_budget).once
      activity2.should_receive(:name).once
      activity2.should_receive(:total_budget).once
      pie = JSON.parse Charts::Activities::Budget.new(activities).google_pie
      pie["values"].should == [["P1", 10.0], ["P2", 5.0]]
      pie["names"]["column1"].should == "Name"
      pie["names"]["column2"].should == "Amount"
    end
  end
end
