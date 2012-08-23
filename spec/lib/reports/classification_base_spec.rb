require 'spec_helper'

describe Reports::ClassificationBase do
  let(:response) { mock :response,
                        :total_spend => 45.0, :total_budget => 15.0}
  let(:report) { Reports::OrganizationLocations.new(response) }
  let(:rows) { [ Reports::Row.new("L1", 20.0, 5.0),
    Reports::Row.new("L2", 25.0, 10.0) ] }

  describe "rounding" do
    let(:rows) { [ Reports::Row.new("L1", 45.009, 15.001)] }

    it "returns false if difference is more than 0.005" do
      report.should_receive(:rows).twice.and_return rows
      report.should_receive(:total_spend).and_return 45.01
      report.should_receive(:total_budget).and_return 15.007
      report.totals_equals_rows?.should be_false
    end

    it "returns true if difference is less than 0.005" do
      report.should_receive(:rows).twice.and_return rows
      report.should_receive(:total_spend).and_return 45.008
      report.should_receive(:total_budget).and_return 15.00
      report.totals_equals_rows?.should be_true
    end
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
      report.stub(:total_spend).and_return(0)
      report.percentage_change.should == 'N/A'
    end

    it "calculates correctly if budget is 0 (returns 0)" do
      report.stub(:total_spend).and_return(1)
      report.stub(:total_budget).and_return(0)
      report.percentage_change.should == -100
    end
  end

  # pie data
  it "should have expenditure pie" do
    report.stub(:collection).and_return(rows)
    Charts::Spend.should_receive(:new).once.with(rows).and_return(mock(:pie, :google_pie => ""))
    report.expenditure_chart
  end

  it "should have budget pie" do
    report.stub(:collection).and_return(rows)
    Charts::Budget.should_receive(:new).once.with(rows).and_return(mock(:pie, :google_pie => ""))
    report.budget_chart
  end
end
