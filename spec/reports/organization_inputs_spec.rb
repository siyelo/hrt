require File.dirname(__FILE__) + '/../spec_helper_lite'

$: << File.join(APP_ROOT, "app/reports")

require 'app/reports/organization_inputs'

class DerpSpend; end
class DerpBudget; end

describe Reports::OrganizationInputs do
  let(:input) { mock :input, :name => 'L0'}
  let(:input1) { mock :input, :name => 'L1' }
  let(:ssplit) { mock :leaf_spend_inputs, :code => input,
                 :cached_amount => 25, :name => input.name,
                 :class => DerpSpend }
  let(:ssplit1) { mock :leaf_spend_inputs, :code => input1,
                  :cached_amount => 20, :name => input1.name,
                  :class => DerpSpend }
  let(:bsplit) { mock :leaf_budget_inputs, :code => input,
                 :cached_amount => 10, :name => input.name,
                 :class => DerpBudget }
  let(:bsplit1) { mock :leaf_budget_inputs, :code => input1,
                  :cached_amount => 5, :name => input1.name,
                  :class => DerpBudget }
  let(:activity) { mock :activity, :name => 'act',
                   :leaf_spend_inputs => [ssplit, ssplit1],
                   :leaf_budget_inputs => [bsplit, bsplit1],
                   :total_spend => 45, :total_budget => 15 }
  let(:other_cost) { mock :activity, :name => 'act',
                   :total_spend => 25, :total_budget => 5}
  let(:response) { mock :response, :activities => [activity, other_cost],
                   :name => 'FY14 Exp', :currency => 'USD',
                   :total_budget => 100, :total_spend => 110 }
  let(:report) { Reports::OrganizationInputs.new(response) }
  let(:inputs) { [ InputSplit.new(input.name, 25.0, 10.0),
                   InputSplit.new(input.name, 20.0, 5.0) ] }

  it "initializes data from given response" do
    report.response.should == response
  end

  it "should have a name" do
    report.name.should == 'FY14 Exp'
  end

  it "has a currency" do
    report.currency.should == 'USD'
  end

  describe "unclassified inputs" do
    it "handles othercosts that do not have their inputs classified" do
      response.activities.should include other_cost
    end

    it "creates a inputs split if for inputs classified" do
      report.stub(:inputs).and_return inputs
      report.inputs.size.should == 2
    end

    describe "#collections" do
      it "returns inputs if the inputs totals equal the responses" do
        inputs = [ InputSplit.new(input.name, 65.0, 60.0),
                   InputSplit.new(input.name, 45.0, 40.0) ]
        report.stub(:inputs).and_return inputs
        report.collection.should == inputs
        report.collection.size.should == 2 #sanity
      end

      it "returns the the inputs with an extra split added if the inputs totals are not equal to the responses" do
        inputs =   [ InputSplit.new(input.name, 65.0, 60.0),
                     InputSplit.new(input.name, 35.0, 20.0) ]
        report.stub(:inputs).and_return inputs
        report.collection.should == inputs
        report.collection.size.should == 3 #sanity
        report.collection.last.total_spend.should == 10
        report.collection.last.total_budget.should == 20
      end
    end
  end

  describe "input_totals with nil values" do
    before :each do
      inputs_with_nil = [ InputSplit.new(input.name, 25.0, 10.0),
                          InputSplit.new(input.name, nil, 5.0) ]
      report.stub(:inputs).and_return(inputs_with_nil)
      report.stub(:method_from_class).with("DerpSpend").and_return :spend
      report.stub(:method_from_class).with("DerpBudget").and_return :budget
    end

    describe "#input_spend" do
      it "works if a split has a value of nil" do
        report.inputs_spend.should == 25
      end
    end

    describe "#inputs_budget" do
      it "works if a split has a value of nil" do
        report.inputs_spend.should == 25
      end
    end
  end

  describe "#total_spend" do
    it "returns the responses total spend as the total spend" do
      report.total_spend.should == response.total_spend
    end
  end

  context "#total_budget" do
    it "returns the responses total spend as the total spend" do
      report.total_spend.should == response.total_spend
    end
  end

  #table data
  it 'returns all inputs current Org (/response)' do
    report.stub(:method_from_class).with("DerpSpend").and_return :spend
    report.stub(:method_from_class).with("DerpBudget").and_return :budget
    report.should_receive(:create_input_splits).once.and_return inputs
    report.inputs.should == inputs
  end

  it "sorts table alphabetically" do
    report.stub(:method_from_class).with("DerpSpend").and_return :spend
    report.stub(:method_from_class).with("DerpBudget").and_return :budget
    sorted_inputs = {:some_sorted_hash => 'yeah!'}
    inputs.should_receive(:sort).and_return sorted_inputs
    report.should_receive(:create_input_splits).once.and_return inputs
    report.inputs.should == sorted_inputs
  end
  # pie data

  it "should have expenditure pie" do
    Charts::Inputs::Spend.stub(:new).and_return(mock(:pie, :google_pie => ""))
    Charts::Inputs::Spend.should_receive(:new).once.with(inputs)
    report.should_receive(:inputs).once.and_return inputs
    pie = report.expenditure_pie
  end

  it "should have budget pie" do
    Charts::Inputs::Budget.stub(:new).and_return(mock(:pie, :google_pie => ""))
    Charts::Inputs::Budget.should_receive(:new).once.with(inputs)
    report.should_receive(:inputs).once.and_return inputs
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
