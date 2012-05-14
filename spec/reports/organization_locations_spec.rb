require File.dirname(__FILE__) + '/../spec_helper_lite'

$: << File.join(APP_ROOT, "app/reports")

require 'app/reports/organization_locations'
require 'bigdecimal'

class DerpSpend; end
class DerpBudget; end

describe Reports::OrganizationLocations do
  let(:location) { mock :location, :name => 'L2'}
  let(:location1) { mock :location, :name => 'L1' }
  let(:ssplit) { mock :coding_spend_district, :code => location,
                 :cached_amount => 25.0, :name => location.name,
                 :class => DerpSpend }
  let(:ssplit1) { mock :coding_spend_district, :code => location1,
                  :cached_amount => 20.0, :name => location1.name,
                  :class => DerpSpend }
  let(:bsplit) { mock :coding_budget_district, :code => location,
                 :cached_amount => 10.0, :name => location.name,
                 :class => DerpBudget }
  let(:bsplit1) { mock :coding_budget_district, :code => location1,
                  :cached_amount => 5.0, :name => location1.name,
                  :class => DerpBudget }
  let(:activity) { mock :activity, :name => 'act',
                   :coding_spend_district => [ssplit, ssplit1],
                   :coding_budget_district => [bsplit, bsplit1],
                   :total_spend => 45.0, :total_budget => 15.0 }
  let(:response) { mock :response, :activities => [activity],
                   :name => 'FY14 Exp', :currency => 'USD',
                   :total_spend => 45.0, :total_budget => 15.0}
  let(:report) { Reports::OrganizationLocations.new(response) }
  let(:rows) { [ Reports::Row.new(location1.name, 20.0, 5.0),
                 Reports::Row.new(location.name, 25.0, 10.0) ] }

  it "should have a name" do
    report.name.should == 'FY14 Exp'
  end

  it "has a currency" do
    report.currency.should == 'USD'
  end

  it "#total_spend" do
    report.total_spend.should == response.total_spend
  end

  it "#total_budget" do
    report.total_spend.should == response.total_spend
  end

  # Table data
  describe "#collection" do
    it 'returns all rows current Org (/response), sorted' do
      report.stub(:method_from_class).with("DerpSpend").and_return :spend
      report.stub(:method_from_class).with("DerpBudget").and_return :budget
      report.collection.should == rows
    end

    it "works if a split has a value of nil" do
      rows_with_nil = [ Reports::Row.new(location1.name, 20.0, 5.0),
                        Reports::Row.new(location.name, 0, 10.0) ]
      ssplit.stub(:cached_amount).and_return nil
      response.stub(:total_spend).and_return BigDecimal.new("20.0")
      report.collection.should == rows_with_nil
    end
  end

  describe "unclassified rows" do
    before :each do
      activity.stub(:coding_spend_district).and_return []
      activity.stub(:coding_budget_district).and_return []
      response.stub(:total_spend).and_return BigDecimal.new("45.015")
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

    it "returns the the rows with an extra split added if the rows totals are not equal to the responses" do
      not_classifed_row = report.collection.last
      not_classifed_row.name.should == "Not Classified"
      not_classifed_row.total_spend.should == 45.02
      not_classifed_row.total_budget.should == 15.0
    end
  end
end
