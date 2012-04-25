require 'json'
require File.dirname(__FILE__) + '/../spec_helper_lite'

$: << File.join(APP_ROOT, "app/charts")

require 'app/charts/projects'

describe Charts::Projects do
  let(:project1){ mock :project, :name => 'p1', :total_spend => 20, :total_budget => 10 }
  let(:project2){ mock :project, :name => 'p2', :total_spend => 10, :total_budget => 5 }
  let(:projects) { [project1, project2] }

  describe Charts::Projects::Spend do
    it "defaults value method to :total_spend" do
      Charts::Projects::Spend.value_method.should == :total_spend
    end

    it "expects those entities respond to name and total_spend" do
      project1.should_receive(:name).once
      project1.should_receive(:total_spend).once
      project2.should_receive(:name).once
      project2.should_receive(:total_spend).once
      pie = JSON.parse Charts::Projects::Spend.new(projects).google_pie
      pie["values"].should == [["P1", 20.0], ["P2", 10.0]]
      pie["names"]["column1"].should == "Name"
      pie["names"]["column2"].should == "Amount"
    end
  end

  describe Charts::Projects::Budget do
    it "defaults value method to :total_budget" do
      Charts::Projects::Budget.value_method.should == :total_budget
    end

    it "expects those entities respond to name and total_budget" do
      project1.should_receive(:name).once
      project1.should_receive(:total_budget).once
      project2.should_receive(:name).once
      project2.should_receive(:total_budget).once
      pie = JSON.parse Charts::Projects::Budget.new(projects).google_pie
      pie["values"].should == [["P1", 10.0], ["P2", 5.0]]
      pie["names"]["column1"].should == "Name"
      pie["names"]["column2"].should == "Amount"
    end
  end
end
