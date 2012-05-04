require File.dirname(__FILE__) + '/../spec_helper_lite'

$: << File.join(APP_ROOT, "app/reports")

require 'app/reports/project_locations'

class DerpSpend; end
class DerpBudget; end

describe Reports::ProjectLocations do
  let(:location) { mock :location, :name => 'L0'}
  let(:location1) { mock :location, :name => 'L1' }
  let(:ssplit) { mock :coding_spend_district, :code => location,
                 :cached_amount => 25, :name => location.name,
                 :class => DerpSpend }
  let(:ssplit1) { mock :coding_spend_district, :code => location1,
                  :cached_amount => 20, :name => location1.name,
                  :class => DerpSpend }
  let(:bsplit) { mock :coding_budget_district, :code => location,
                 :cached_amount => 10, :name => location.name,
                 :class => DerpBudget }
  let(:bsplit1) { mock :coding_budget_district, :code => location1,
                  :cached_amount => 5, :name => location1.name,
                  :class => DerpBudget }
  let(:activity) { mock :activity, :name => 'act',
                   :coding_spend_district => [ssplit, ssplit1],
                   :coding_budget_district => [bsplit, bsplit1] }
  let(:activity1) { mock :activity, :name => 'activity1', :total_spend => "5", :total_budget => "10" }
  let(:activities) { [activity, activity1] }
  let(:project) { mock :project, :activities => activities,
    :total_spend => 10, :total_budget => 20, :name => 'Project1', :currency => 'USD' }
  let(:report) { Reports::ProjectLocations.new(project) }
  let(:locations) { [ LocationSplit.new(location.name, 25.0, 10.0),
                      LocationSplit.new(location.name, 20.0, 5.0) ] }

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
    Charts::ProjectLocations::Spend.stub(:new).and_return(mock(:pie, :google_pie => ""))
    Charts::ProjectLocations::Spend.should_receive(:new).once.with(locations)
    report.should_receive(:locations).once.and_return locations
    pie = report.expenditure_pie
  end

  it "should have budget pie" do
    Charts::ProjectLocations::Budget.stub(:new).and_return(mock(:pie, :google_pie => ""))
    Charts::ProjectLocations::Budget.should_receive(:new).once.with(locations)
    report.should_receive(:locations).once.and_return locations
    report.budget_pie
  end

  #table data
  it 'returns all locations' do
    report.stub(:method_from_class).with("DerpSpend").and_return :spend
    report.stub(:method_from_class).with("DerpBudget").and_return :budget
    report.should_receive(:create_location_splits).once.and_return locations
    report.locations.should == locations
  end

  it "sorts table alphabetically" do
    report.stub(:method_from_class).with("DerpSpend").and_return :spend
    report.stub(:method_from_class).with("DerpBudget").and_return :budget
    sorted_locations = {:some_sorted_hash => 'yeah!'}
    locations.should_receive(:sort).and_return sorted_locations
    report.should_receive(:create_location_splits).once.and_return locations
    report.locations.should == sorted_locations
  end
  # pie data

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
