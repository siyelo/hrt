require File.dirname(__FILE__) + '/../spec_helper_lite'

$: << File.join(APP_ROOT, "app/reports")

require 'app/reports/organization'

describe Reports::Organization do
  let(:project) { mock :project, :name => 'proj', :total_spend => "5", :total_budget => "10" }
  let(:project1) { mock :project, :name => 'proj1', :total_spend => "5", :total_budget => "10" }
  let(:projects) { [project, project1] }
  let(:response) { mock :response, :projects => projects,
    :total_spend => 10, :total_budget => 20, :name => 'FY14 Exp', :currency => 'USD' }
  let(:report) { Reports::Organization.new(response) }

  it "initializes by period" do
    report.class.should == Reports::Organization
  end

  it 'returns all projects and non-project other costs for current Org (/response), sorted by name' do
    othercost = mock :othercost, :name => 'aa_othercost', :total_spend => "5", :total_budget => "10"
    othercost1 = mock :othercost, :name => 'zz_othercost', :total_spend => "5", :total_budget => "10"
    othercosts = [othercost, othercost1]
    response.stub_chain(:other_costs, :without_project).and_return othercosts
    unsorted = projects + othercosts
    sorted = [othercost, project, project1, othercost1]
    report.projects_and_other_costs.should == sorted
  end

  it "should give total org spend" do
    report.total_spend.should == 10
  end

  it "should give total org budget" do
    report.total_budget.should == 20
  end

  it "should have a name" do
    report.name.should == 'FY14 Exp'
  end

  it "has a currency" do
    report.currency.should == 'USD'
  end

  it "should have expenditure pie" do
    Charts::Projects::Spend.stub(:new).and_return(mock(:pie, :google_pie => ""))
    Charts::Projects::Spend.should_receive(:new).once.with(projects)
    report.should_receive(:projects_and_other_costs).once.and_return projects # avoid sorted scope
    pie = report.expenditure_pie
  end

  it "should have budget pie" do
    Charts::Projects::Budget.stub(:new).and_return(mock(:pie, :google_pie => ""))
    Charts::Projects::Budget.should_receive(:new).once.with(projects)
    report.should_receive(:projects_and_other_costs).once.and_return projects # avoid sorted scope
    report.budget_pie
  end

  describe "#percentage_change" do
    it "calculates the % spent last year against this years budget" do
      report.percentage_change.should == 100
    end

    it "calculates the % spent as negative" do
      response.stub(:total_budget).and_return 5
      report.percentage_change.should == -50
    end

    it "should round to 1 decimal" do
      response.stub(:total_spend).and_return 9.11
      response.stub(:total_budget).and_return 11.23
      report.percentage_change.should == 23.3 #23.27 rounded up
    end

    it "calculates correctly if spend is 0 (returns 0)" do
      response.should_receive(:total_spend).once.and_return(0)
      report.percentage_change.should == 0
    end

    it "calculates correctly if budget is 0 (returns 0)" do
      response.should_receive(:total_budget).once.and_return(0)
      report.percentage_change.should == 0
    end
  end

end
