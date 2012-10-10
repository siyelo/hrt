require 'spec_helper'

describe Reports::OrganizationLocations do
  let(:location) { mock :location, name: 'L2'}
  let(:location1) { mock :location, name: 'L1' }
  let(:ssplit) { mock :location_spend_split, code: location, spend: true,
       cached_amount: 25.0, name: location.name, currency: 'USD' }
  let(:ssplit1) { mock :location_spend_split, code: location1, spend: true,
       cached_amount: 20.0, name: location1.name, currency: 'USD' }
  let(:bsplit) { mock :location_budget_split, code: location, spend: false,
       cached_amount: 10.0, name: location.name, currency: 'USD' }
  let(:bsplit1) { mock :location_budget_split, code: location1, spend: false,
       cached_amount: 5.0, name: location1.name, currency: 'USD' }
  let(:activity) { mock :activity, name: 'act',
                   total_spend: 45.0, total_budget: 15.0 }
  let(:response) { mock :response, activities: [activity], name: 'FY14 Exp',
       currency: 'USD', total_spend: 45.0, total_budget: 15.0}
  let(:report) { Reports::OrganizationLocations.new(response) }
  let(:rows) { [ Reports::Row.new(location1.name, 20.0, 5.0),
                 Reports::Row.new(location.name, 25.0, 10.0) ] }

  describe "unclassified inputs" do
    before :each do
      activity.stub_chain(:code_splits, :locations, :budget).and_return([bsplit, bsplit1])
      activity.stub_chain(:code_splits, :locations, :spend).and_return([ssplit, ssplit1])
    end

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

    describe "#collection" do
      it 'returns all rows current Org (/response), sorted' do
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
  end

  describe "unclassified rows" do
    before :each do
      activity.stub_chain(:code_splits, :locations, :budget).and_return([])
      activity.stub_chain(:code_splits, :locations, :spend).and_return([])
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
