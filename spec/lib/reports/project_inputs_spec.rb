require 'spec_helper'

describe Reports::ProjectInputs do
  let(:input) { mock :input, name: 'L2'}
  let(:input1) { mock :input, name: 'L1' }
  let(:ssplit) { mock :input_split, code: input, spend: true,
          cached_amount: 25.0, name: input.name, currency: 'USD' }
  let(:ssplit1) { mock :input_split, code: input1, spend: true,
          cached_amount: 20.0, name: input1.name, currency: 'USD' }
  let(:bsplit) { mock :input_split, code: input, spend: false,
          cached_amount: 10.0, name: input.name, currency: 'USD' }
  let(:bsplit1) { mock :input_split, code: input1, spend: false,
          cached_amount: 5.0, name: input1.name, currency: 'USD' }
  let(:activity) { mock :activity, name: 'act',
                   total_spend: 45.0, total_budget: 15.0 }
  let(:project) { mock :project, activities: [activity],
                  name: 'Project1', currency: 'USD',
                  total_spend: 45.0, total_budget: 15.0 }
  let(:report) { Reports::ProjectInputs.new(project) }
  let(:rows) { [ Reports::Row.new(input1.name, 20.0, 5.0),
                 Reports::Row.new(input.name, 25.0, 10.0) ] }

  describe "general" do
    before :each do
      activity.stub_chain(:code_splits, :inputs, :budget, :with_codes).and_return([bsplit, bsplit1])
      activity.stub_chain(:code_splits, :inputs, :spend, :with_codes).and_return([ssplit, ssplit1])
    end

    it "should have a name" do
      report.name.should == 'Project1'
    end

    it "has a currency" do
      report.currency.should == 'USD'
    end

    it "#total_spend" do
      report.total_spend.should == project.total_spend
    end

    it "#total_budget" do
      report.total_spend.should == project.total_spend
    end

    describe "#collection" do
      it 'returns all locations current Org (/project), sorted' do
        report.collection.should == rows
      end

      it "works if a split has a value of nil" do
        splits_w_nil = [ Reports::Row.new(input1.name, 20.0, 5.0),
                         Reports::Row.new(input.name, 0, 10.0) ]
        ssplit.stub(:cached_amount).and_return nil
        project.stub(:total_spend).and_return BigDecimal.new("20.0")
        report.collection.should == splits_w_nil
      end
    end
  end

  describe "unclassified inputs" do
    before :each do
      activity.stub_chain(:code_splits, :inputs, :budget, :with_codes).and_return([])
      activity.stub_chain(:code_splits, :inputs, :spend, :with_codes).and_return([])
      project.stub(:total_spend).and_return BigDecimal.new("45.015")
    end

    it "rounds all amounts" do
      not_classified_input = report.collection.last
      not_classified_input.total_spend.should == 45.02
    end

    it "does the not-classified calculation before rounding" do
      report.stub(:rows_spend).and_return BigDecimal.new("45.011")
      not_classified_input = report.collection.last
      not_classified_input.total_spend.should == 0 # .015 - .011 == 0.004 - rounded down to zero
    end

    it "returns the the inputs with an extra split added if the inputs totals are not equal to the project" do
      not_classified_input = report.collection.last
      not_classified_input.name.should == "Not Classified"
      not_classified_input.total_spend.should == 45.02
      not_classified_input.total_budget.should == 15.0
    end
  end
end
