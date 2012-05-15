require File.dirname(__FILE__) + '/../spec_helper_lite'

$: << File.join(APP_ROOT, "app/reports")

require 'app/reports/reporters'

describe Reports::Reporters do
  let(:response1) { mock :response,
                    :tot_spend => 100, :tot_budget => 20, :org_name => 'one', :currency => 'USD' }
  let(:response2) { mock :response,
                    :tot_spend => 400, :tot_budget => 40, :org_name => 'two', :currency => 'USD' }
  let(:response3) { mock :response,
                    :tot_spend => 300, :tot_budget => 60, :org_name => 'three', :currency => 'USD' }
  let(:responses) { [response1, response2, response3] }
  let(:rows) { [ Reports::Row.new("two", 400.0, 40.0),
                 Reports::Row.new("three", 300.0, 60.0) ] }

  let(:request) { mock :request, :data_responses => responses, :title => "Yaw"}

  let(:report) { Reports::Reporters.new(request) }

  it "has a name" do
    request.should_receive(:name).and_return request.title
    report.name.should == 'Yaw'
  end

  it "has a currency" do
    report.currency.should == 'USD'
  end

  it "#total_spend" do
    report.should_receive(:collection).once.and_return rows
    report.total_spend.should == 700
  end

  it "#total_budget" do
    report.should_receive(:collection).once.and_return rows
    report.total_budget.should == 100
  end

  it "#collection is made up of Report::Row objects" do
    report.should_receive(:rows).once.and_return responses
    rows = report.collection
    rows.first.class.should == Reports::Row
    rows.first.total_spend.should == BigDecimal.new("100")
    rows.first.total_budget.should == BigDecimal.new("20")
  end

  describe "charts" do
    it "#expenditure_pie only displays top 10 values" do
      Reports::Reporters::NUMBER_OF_VALUES_IN_CHARTS.should == 10
    end

    it "#expenditure_pie only displays the top spenders in the data_request" do
      Reports::Reporters.send(:remove_const, 'NUMBER_OF_VALUES_IN_CHARTS')
      Reports::Reporters.const_set('NUMBER_OF_VALUES_IN_CHARTS', 2)
      Charts::Spend.stub(:new).and_return(mock(:pie, :google_pie => ""))
      Charts::Spend.should_receive(:new).once.with(rows)
      report.should_receive(:rows).once.and_return responses
      report.expenditure_pie
    end

    it "#budget_pie only displays the top spenders in the data_request" do
      Reports::Reporters.send(:remove_const, 'NUMBER_OF_VALUES_IN_CHARTS')
      Reports::Reporters.const_set('NUMBER_OF_VALUES_IN_CHARTS', 2)
      Charts::Spend.stub(:new).and_return(mock(:pie, :google_pie => ""))
      Charts::Spend.should_receive(:new).once.with(rows)
      report.should_receive(:rows).once.and_return responses
      report.expenditure_pie
    end
  end
end
