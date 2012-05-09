require File.dirname(__FILE__) + '/../spec_helper_lite'

$: << File.join(APP_ROOT, "app/reports")

require 'app/reports/project'

describe Reports::Project do
  let(:activity) { mock :activity, :name => 'activity', :total_spend => "5", :total_budget => "10" }
  let(:activity1) { mock :activity, :name => 'activity1', :total_spend => "5", :total_budget => "10" }
  let(:activities) { [activity, activity1] }
  let(:project) { mock :project, :activities => activities,
    :total_spend => 10, :total_budget => 20, :name => 'Project1', :currency => 'USD' }
  let(:report) { Reports::Project.new(project) }

  it 'returns all activities and other costs for current Project sorted by name' do
    othercost = mock :othercost, :name => 'aa_othercost', :total_spend => "5", :total_budget => "10"
    othercost1 = mock :othercost, :name => 'zz_othercost', :total_spend => "5", :total_budget => "10"
    othercosts = [othercost, othercost1]
    project.stub_chain(:activities, :sorted).and_return othercosts
    report.collection.should == othercosts
  end

  it "#total_spend" do
    report.total_spend.should == 10
  end

  it "#total_budget" do
    report.total_budget.should == 20
  end

  it "should have a name" do
    report.name.should == 'Project1'
  end

  it "has a currency" do
    report.currency.should == 'USD'
  end
end
