require 'spec_helper'

class DerpSpend; end
class DerpBudget; end

describe Reports::ProjectLocations do
  let(:location) { mock :location, :name => 'L2'}
  let(:location1) { mock :location, :name => 'L1' }
  let(:ssplit) { mock :location_spend_split, :code => location,
                 :cached_amount => 25.0, :name => location.name,
                 :currency => 'USD', :class => DerpSpend }
  let(:ssplit1) { mock :location_spend_split, :code => location1,
                  :cached_amount => 20.0, :name => location1.name,
                  :currency => 'USD', :class => DerpSpend }
  let(:bsplit) { mock :location_budget_split, :code => location,
                 :cached_amount => 10.0, :name => location.name,
                 :currency => 'USD', :class => DerpBudget }
  let(:bsplit1) { mock :location_budget_split, :code => location1,
                  :cached_amount => 5.0, :name => location1.name,
                  :currency => 'USD', :class => DerpBudget }
  let(:activity) { mock :activity, :name => 'act',
                   :location_spend_splits => [ssplit, ssplit1],
                   :location_budget_splits => [bsplit, bsplit1],
                   :total_spend => 45.0, :total_budget => 15.0 }
  let(:project) { mock :project, :name => 'Project1',
                  :activities => [activity], :currency => 'USD',
                  :total_spend => 45.0, :total_budget => 15.0}
  let(:report) { Reports::ProjectLocations.new(project) }
  let(:rows) { [ Reports::Row.new(location1.name, 20.0, 5.0),
                 Reports::Row.new(location.name, 25.0, 10.0) ] }

  it "should have a name" do
    report.name.should == 'Project1'
  end

  it "has a currency" do
    report.currency.should == 'USD'
  end

  it "#total_spend" do
    report.total_spend.should == activity.total_spend
  end

  it "#total_budget" do
    report.total_spend.should == activity.total_spend
  end

  #table data
  describe "#collection" do
    it 'returns all locations current Org (/response), sorted' do
      report.stub(:method_from_class).with("DerpSpend").and_return :spend
      report.stub(:method_from_class).with("DerpBudget").and_return :budget
      report.collection.should == rows
    end

    it "works if a split has a value of nil" do
      locations_with_nil = [ Reports::Row.new(location1.name, 20.0, 5.0),
                             Reports::Row.new(location.name, 0, 10.0) ]
      ssplit.stub(:cached_amount).and_return nil
      project.stub(:total_spend).and_return BigDecimal.new("20.0")
      report.collection.should == locations_with_nil
    end
  end

  describe "unclassified locations" do
    before :each do
      activity.stub(:location_spend_splits).and_return []
      activity.stub(:location_budget_splits).and_return []
      project.stub(:total_spend).and_return BigDecimal.new("45.015")
    end

    it "rounds all amounts" do
      not_classifed_row = report.collection.last
      not_classifed_row.total_spend.should == 45.02
    end

    it "does the not-classified calculation before rounding" do
      report.stub(:rows_spend).and_return BigDecimal.new("45.011")
      not_classifed_row = report.collection.last
      not_classifed_row.total_spend.to_s.should == "0.0" # .015 - .011 == 0.004 - rounded down to zero
    end

    it "returns the the locations with an extra split added if the locations totals are not equal to the responses" do
      not_classifed_row = report.collection.last
      not_classifed_row.name.should == "Not Classified"
      not_classifed_row.total_spend.should == 45.02
    end
  end
end
