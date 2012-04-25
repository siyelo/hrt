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
    report.activities_and_other_costs.should == othercosts
  end

  it "should give total org spend" do
    report.total_spend.should == 10
  end

  it "should give total org budget" do
    report.total_budget.should == 20
  end

  it "should have a name" do
    report.name.should == 'Project1'
  end

  it "has a currency" do
    report.currency.should == 'USD'
  end

  it "should have expenditure pie" do
    Charts::Activities::Spend.stub(:new).and_return(mock(:pie, :google_pie => ""))
    Charts::Activities::Spend.should_receive(:new).once.with(activities)
    report.should_receive(:activities_and_other_costs).once.and_return activities
    pie = report.expenditure_pie
  end

  it "should have budget pie" do
    Charts::Activities::Budget.stub(:new).and_return(mock(:pie, :google_pie => ""))
    Charts::Activities::Budget.should_receive(:new).once.with(activities)
    report.should_receive(:activities_and_other_costs).once.and_return activities # avoid sorted scope
    report.budget_pie
  end

  describe "#percentage_change" do
    it "calculates the % spent last year against this years budget" do
      report.percentage_change.should == 100
    end

    it "calculates the % spent as negative" do
      project.stub(:total_budget).and_return 5
      report.percentage_change.should == -50
    end

    it "should round to 1 decimal" do
      project.stub(:total_spend).and_return 9.11
      project.stub(:total_budget).and_return 11.23
      report.percentage_change.should == 23.3 #23.27 rounded up
    end

    it "calculates correctly if spend is 0 (returns 0)" do
      project.should_receive(:total_spend).once.and_return(0)
      report.percentage_change.should == 0
    end

    it "calculates correctly if budget is 0 (returns 0)" do
      project.should_receive(:total_budget).once.and_return(0)
      report.percentage_change.should == 0
    end
  end

end
