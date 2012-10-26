require 'spec_helper'

describe Reports::ActivityInputs do
  let(:input) { mock :input, name: 'L2'}
  let(:input1) { mock :input, name: 'L1' }
  let(:ssplit) { mock :coding_spend_input, code: input, spend: true,
    cached_amount: 25.0, name: input.name, currency: 'USD' }
  let(:ssplit1) { mock :coding_spend_input, code: input1, spend: true,
    cached_amount: 20.0, name: input1.name, currency: 'USD' }
  let(:bsplit) { mock :coding_budget_input, code: input, spend: false,
    cached_amount: 10.0, name: input.name, currency: 'USD' }
  let(:bsplit1) { mock :coding_budget_input, code: input1, spend: false,
    cached_amount: 5.0, name: input1.name, currency: 'USD' }
  let(:activity) { mock :activity, name: 'act',
    total_spend: 45.0, total_budget: 15.0, currency: 'USD'}
  let(:report) { Reports::ActivityInputs.new(activity) }
  let(:rows) { [ Reports::Row.new(input1.name, 20.0, 5.0),
    Reports::Row.new(input.name, 25.0, 10.0) ] }

  describe "general" do
    before :each do
      activity.stub_chain(:code_splits, :inputs, :budget, :with_codes).and_return([bsplit, bsplit1])
      activity.stub_chain(:code_splits, :inputs, :spend, :with_codes).and_return([ssplit, ssplit1])
    end

    it "should have a name" do
      report.name.should == 'act'
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

    describe "#collection" do
      it 'returns all rows, sorted' do
        report.collection.should == rows
      end

      it "works if a split has a value of nil" do
        inputs_with_nil = [ Reports::Row.new(input1.name, 20.0, 5.0),
          Reports::Row.new(input.name, 0, 10.0) ]
        ssplit.stub(:cached_amount).and_return nil
        activity.stub(:total_spend).and_return BigDecimal.new("20.0")
        report.collection.should == inputs_with_nil
      end
    end
  end

  describe "unclassified inputs" do
    before :each do
      activity.stub_chain(:code_splits, :inputs, :budget, :with_codes).and_return([])
      activity.stub_chain(:code_splits, :inputs, :spend, :with_codes).and_return([])
      activity.stub(:total_spend).and_return BigDecimal.new("45.015")
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

    it "returns the the inputs with an extra split added if the inputs totals are not equal to the responses" do
      not_classifed_row = report.collection.last
      not_classifed_row.name.should == "Not Classified"
      not_classifed_row.total_spend.should == 45.02
    end
  end
end
