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
                   :coding_budget_district => [bsplit, bsplit1],
                   :total_spend => 45, :total_budget => 15 }
  let(:other_cost) { mock :activity, :name => 'act',
                   :total_spend => 25, :total_budget => 5}
  let(:project) { mock :project, :name => 'Project1',
                  :activities => [activity, other_cost], :currency => 'USD',
                  :total_spend => 110, :total_budget => 100}
  let(:report) { Reports::ProjectLocations.new(project) }
  let(:locations) { [ LocationSplit.new(location.name, 25.0, 10.0),
                      LocationSplit.new(location.name, 20.0, 5.0) ] }

  it "initializes data from given projects" do
    report.project.should == project
  end

  it "should have a name" do
    report.name.should == 'Project1'
  end

  it "has a currency" do
    report.currency.should == 'USD'
  end

  describe "unclassified locations" do
    it "handles othercosts/activities that do not have their locations classified" do
      project.activities.should include other_cost
    end

    it "creates a location split if for  locations classified" do
      report.stub(:locations).and_return locations
      report.locations.size.should == 2
    end

    describe "#collections" do
      it "returns locations if the locations totals equal the projects" do
        locations =   [ LocationSplit.new(location.name, 65.0, 60.0),
                        LocationSplit.new(location.name, 45.0, 40.0) ]
        report.stub(:locations).and_return locations
        report.collection.should == locations
        report.collection.size.should == 2 #sanity
      end

      it "returns the the locations with an extra split added if the locations totals are not equal to the projects" do
        locations =   [ LocationSplit.new(location.name, 65.0, 60.0),
                        LocationSplit.new(location.name, 35.0, 20.0) ]
        report.stub(:locations).and_return locations
        report.collection.should == locations
        report.collection.size.should == 3 #sanity
        report.collection.last.total_spend.should == 10
        report.collection.last.total_budget.should == 20
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
      report.total_spend.should == project.total_spend
    end
  end

  context "#total_budget" do
    it "returns the projects total spend as the total spend" do
      report.total_spend.should == project.total_spend
    end
  end

  it "should have expenditure pie" do
    Charts::Locations::Spend.stub(:new).and_return(mock(:pie, :google_pie => ""))
    Charts::Locations::Spend.should_receive(:new).once.with(locations)
    report.stub(:locations).and_return locations
    pie = report.expenditure_pie
  end

  it "should have budget pie" do
    Charts::Locations::Budget.stub(:new).and_return(mock(:pie, :google_pie => ""))
    Charts::Locations::Budget.should_receive(:new).once.with(locations)
    report.stub(:locations).once.and_return locations
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
      report.stub(:total_spend).and_return 10
      report.stub(:total_budget).and_return 20
      report.percentage_change.should == 100
    end

    it "calculates the % spent as negative" do
      report.stub(:total_spend).and_return 10
      report.stub(:total_budget).and_return 5
      report.percentage_change.should == -50
    end

    it "should round to 1 decimal" do
      report.stub(:total_spend).and_return 9.11
      report.stub(:total_budget).and_return 11.23
      report.percentage_change.should == 23.3 #23.27 rounded up
    end

    it "calculates correctly if spend is 0 (returns 0)" do
      report.stub(:total_spend).and_return 0
      report.stub(:total_budget).and_return 5
      report.percentage_change.should == 0
    end

    it "calculates correctly if budget is 0 (returns 0)" do
      report.stub(:total_spend).and_return 10
      report.stub(:total_budget).and_return 0
      report.percentage_change.should == 0
    end
  end
end
