require File.dirname(__FILE__) + '/../spec_helper_lite'

$: << File.join(APP_ROOT, "app/reports")

require 'app/reports/activity_locations'

class DerpSpend; end
class DerpBudget; end

describe Reports::ActivityLocations do
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
                   :coding_budget_district => [bsplit, bsplit1],
                   :total_spend => 45, :total_budget => 15 }
  let(:response) { mock :response, :activities => [activity],
                   :name => 'FY14 Exp', :currency => 'USD' }
  let(:report) { Reports::ActivityLocations.new(activity) }
  let(:locations) { [ LocationSplit.new(location.name, 25.0, 10.0),
                      LocationSplit.new(location.name, 20.0, 5.0) ] }

  it "initializes data from given activity" do
    report.activity.should == activity
  end

  it "should have a name" do
    report.name.should == 'act'
  end

  it "has a currency" do
    activity.should_receive(:data_response).once.and_return(response)
    response.should_receive(:currency).once.and_return('USD')
    report.currency.should == 'USD'
  end

  describe "unclassified locations" do
    it "creates a location split if for locations classified" do
      report.stub(:locations).and_return locations
      report.locations.size.should == 2
    end

    describe "#collections" do
      it "returns locations if the locations totals equal the projects" do
        locations =   [ LocationSplit.new(location.name, 30.0, 5.0),
                        LocationSplit.new(location.name, 15.0, 10.0) ]
        report.stub(:locations).and_return locations
        report.collection.should == locations
        report.collection.size.should == 2 #sanity
      end

      it "returns the the locations with an extra split added if the locations totals are not equal to the projects" do
        locations =   [ LocationSplit.new(location.name, 20.0, 5.0),
                        LocationSplit.new(location.name, 15.0, 5.0) ]
        report.stub(:locations).and_return locations
        report.collection.should == locations
        report.collection.size.should == 3 #sanity
        report.collection.last.total_spend.should == 10
        report.collection.last.total_budget.should == 5
      end
    end
  end

  describe "location_totals with nil values" do
    before :each do
      locations_with_nil = [ LocationSplit.new(location.name, 25.0, 10.0),
                             LocationSplit.new(location.name, nil, 5.0) ]
      report.stub(:locations).and_return(locations_with_nil)
      report.stub(:method_from_class).with("DerpSpend").and_return :spend
      report.stub(:method_from_class).with("DerpBudget").and_return :budget
    end

    describe "#location_spend" do
      it "works if a split has a value of nil" do
        report.locations_spend.should == 25
      end
    end

    describe "#locations_budget" do
      it "works if a split has a value of nil" do
        report.locations_spend.should == 25
      end
    end
  end

  describe "#total_spend" do
    it "returns the projects total spend as the total spend" do
      report.total_spend.should == activity.total_spend
    end
  end

  context "#total_budget" do
    it "returns the projects total spend as the total spend" do
      report.total_spend.should == activity.total_spend
    end
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
    report.stub(:locations).once.and_return locations
    pie = report.expenditure_pie
  end

  it "should have budget pie" do
    Charts::Locations::Budget.stub(:new).and_return(mock(:pie, :google_pie => ""))
    Charts::Locations::Budget.should_receive(:new).once.with(locations)
    report.stub(:locations).once.and_return locations
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
