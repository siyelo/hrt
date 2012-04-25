require File.dirname(__FILE__) + '/../spec_helper_lite'

$: << File.join(APP_ROOT, "app/reports")

require 'app/reports/location'

class DerpSpend; end
class DerpBudget; end

describe Reports::Location do
  let(:location) { mock :location, :name => 'L0'}
  let(:location1) { mock :location, :name => 'L1' }
  let(:ssplit) { mock :coding_spend_district, :code => location, :cached_amount => 25,
                 :name => location.name, :class => DerpSpend }
  let(:ssplit1) { mock :coding_spend_district, :code => location1, :cached_amount => 20,
                  :name => location1.name , :class => DerpSpend }
  let(:bsplit) { mock :coding_budget_district, :code => location, :cached_amount => 10,
                 :name => location.name , :class => DerpBudget }
  let(:bsplit1) { mock :coding_budget_district, :code => location1, :cached_amount => 5,
                  :name => location1.name , :class => DerpBudget }
  let(:activity) { mock :activity, :name => 'act', :coding_spend_district => [ssplit, ssplit1],
                   :coding_budget_district => [bsplit, bsplit1] }
  let(:response) { mock :response, :activities => [activity], :name => 'FY14 Exp', :currency => 'USD' }
  let(:report) { Reports::Location.new(response) }
  let(:lsplit1) { mock :location_split, :spend => 25, :budget => 10, :name => location.name}
  let(:lsplit2) { mock :location_split, :spend => 20, :budget => 5, :name => location1.name}
  let(:locations) { [ LocationSplit.new(location.name, 25.0, 10.0),
                      LocationSplit.new(location.name, 20.0, 5.0) ] }

  it "initializes data from given response" do
    report.response.should == response
  end

  it "should have a name" do
    report.name.should == 'FY14 Exp'
  end

  it "has a currency" do
    report.currency.should == 'USD'
  end

  it "should give total location spend" do
    report.stub(:method_from_class).with("DerpSpend").and_return :spend
    report.stub(:method_from_class).with("DerpBudget").and_return :budget
    report.total_spend.should == 45
  end

  it "should give total location budget" do
    report.stub(:method_from_class).with("DerpSpend").and_return :spend
    report.stub(:method_from_class).with("DerpBudget").and_return :budget
    report.total_budget.should == 15
  end

  #table data
  it 'returns all locations current Org (/response)' do
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

  it "should have expenditure pie" do
    Charts::Locations::Spend.stub(:new).and_return(mock(:pie, :google_pie => ""))
    Charts::Locations::Spend.should_receive(:new).once.with(locations)
    report.should_receive(:locations).once.and_return locations
    pie = report.expenditure_pie
  end

  it "should have budget pie" do
    Charts::Locations::Budget.stub(:new).and_return(mock(:pie, :google_pie => ""))
    Charts::Locations::Budget.should_receive(:new).once.with(locations)
    report.should_receive(:locations).once.and_return locations
    report.budget_pie
  end

  describe "#percentage_change" do
    it "calculates the % spent last year against this years budget" do
      report.stub(:total_spend).and_return 10
      report.stub(:total_budget).and_return 20
      report.percentage_change.should == 100
    end

    it "calculates the % spent as negative" do
      report.stub(:total_spend).and_return 10
      report.stub(:total_budget).and_return 5
      report.percentage_change.should == -50
    end

    it "calculates correctly if spend is 0 (returns 0)" do
      report.should_receive(:total_spend).once.and_return(0)
      report.percentage_change.should == 0
    end

    it "calculates correctly if budget is 0 (returns 0)" do
      report.should_receive(:total_spend).once.and_return(1)
      report.should_receive(:total_budget).once.and_return(0)
      report.percentage_change.should == 0
    end
  end
end
