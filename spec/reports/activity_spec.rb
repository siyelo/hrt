require File.dirname(__FILE__) + '/../spec_helper_lite'

$: << File.join(APP_ROOT, "app/reports")

require 'app/reports/activity'

describe Reports::Activity do
  let(:activity) { mock :activity, :name => 'activity', :total_spend => 10, :total_budget => 20, :currency => "USD" }
  let(:implementer_split) { mock :implementer_split, :organization_name => 'aa_implementer', :spend => 5, :budget => 10 }
  let(:implementer_split2) { mock :implementer_split, :organization_name => 'zz_implementer', :spend => 5, :budget => 10 }
  let(:implementer_splits) { [implementer_split, implementer_split2] }
  let(:report) { Reports::Activity.new(activity) }

  it 'returns all activities and other costs for current Project sorted by name' do
    implementer_splits = [implementer_split, implementer_split2]
    activity.stub_chain(:implementer_splits, :sorted, :find).and_return implementer_splits
    report.implementer_splits.should == implementer_splits
  end

  it "should give total org spend" do
    report.total_spend.should == 10
  end

  it "should give total org budget" do
    report.total_budget.should == 20
  end

  it "should have a name" do
    report.name.should == 'activity'
  end

  it "has a currency" do
    report.currency.should == 'USD'
  end

  it "should have expenditure pie" do
    Charts::ImplementerSplits::Spend.stub(:new).and_return(mock(:pie, :google_pie => ""))
    Charts::ImplementerSplits::Spend.should_receive(:new).once.with(implementer_splits)
    report.should_receive(:implementer_splits).once.and_return implementer_splits
    pie = report.expenditure_pie
  end

  it "should have budget pie" do
    Charts::ImplementerSplits::Budget.stub(:new).and_return(mock(:pie, :google_pie => ""))
    Charts::ImplementerSplits::Budget.should_receive(:new).once.with(implementer_splits)
    report.should_receive(:implementer_splits).once.and_return implementer_splits # avoid sorted scope
    report.budget_pie
  end

  describe "#percentage_change" do
    it "calculates the % spent last year against this years budget" do
      report.percentage_change.should == 100
    end

    it "calculates the % spent as negative" do
      activity.stub(:total_budget).and_return 5
      report.percentage_change.should == -50
    end

    it "should round to 1 decimal" do
      activity.stub(:total_spend).and_return 9.11
      activity.stub(:total_budget).and_return 11.23
      report.percentage_change.should == 23.3 #23.27 rounded up
    end

    it "calculates correctly if spend is 0 (returns 0)" do
      activity.should_receive(:total_spend).once.and_return(0)
      report.percentage_change.should == 0
    end

    it "calculates correctly if budget is 0 (returns 0)" do
      activity.should_receive(:total_budget).once.and_return(0)
      report.percentage_change.should == 0
    end
  end

end
