require File.dirname(__FILE__) + '/../spec_helper_lite'

$: << File.join(APP_ROOT, "app/reports")

require 'app/reports/activity'

describe Reports::Activity do
  let(:activity) { mock :activity, :name => 'activity',
                   :total_spend => 10, :total_budget => 20, :currency => "USD" }
  let(:implementer_split) { mock :implementer_split,
                            :organization_name => 'aa_implementer',
                            :spend => 5, :budget => 10 }
  let(:implementer_split2) { mock :implementer_split,
                             :organization_name => 'zz_implementer',
                             :spend => 5, :budget => 10 }
  let(:implementer_splits) { [implementer_split, implementer_split2] }
  let(:report) { Reports::Activity.new(activity) }

  it 'returns all activities and other costs for current Project sorted by name' do
    implementer_splits = [implementer_split, implementer_split2]
    activity.stub_chain(:implementer_splits, :sorted, :find).and_return implementer_splits
    report.collection.should == implementer_splits
  end

  it "#total_spend" do
    report.total_spend.should == 10
  end

  it "#total_budget" do
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
    report.should_receive(:collection).once.and_return implementer_splits
    report.expenditure_chart
  end

  it "should have budget pie" do
    Charts::ImplementerSplits::Budget.stub(:new).and_return(mock(:pie, :google_pie => ""))
    Charts::ImplementerSplits::Budget.should_receive(:new).once.with(implementer_splits)
    report.should_receive(:collection).once.and_return implementer_splits
    report.budget_chart
  end

end
