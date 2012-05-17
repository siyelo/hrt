require File.dirname(__FILE__) + '/../spec_helper_lite'

$: << File.join(APP_ROOT, "app/reports")

require 'app/reports/funders'

describe Reports::Funders do
  let(:organization1) { mock :organization, :name => "org1",
                        :currency => 'USD'}
  let(:organization2) { mock :organization, :name => "org2",
                        :currency => 'RWF'}
  let(:funding_flow1) { mock :response,
    :spend => 100, :budget => 20, :organization => organization1 }
  let(:funding_flow2) { mock :response,
    :spend => 400, :budget => 40, :organization => organization1}
  let(:funding_flow3) { mock :response,
    :spend => 300, :budget => 60, :organization => organization2}
  let(:funding_flows) { [funding_flow1, funding_flow2, funding_flow3] }
  let(:rows) { [ Reports::Row.new("two", 400.0, 40.0),
                 Reports::Row.new("three", 300.0, 60.0) ] }

  let(:request) { mock :request, :title => "Yaw"}
  let(:report) { Reports::Funders.new(request) }

  it "has a name" do
    request.should_receive(:name).and_return request.title
    report.name.should == 'Yaw'
  end

  it "has a currency" do
    report.currency.should == 'USD'
  end

  it "#collection is made up of funding_flows embedded in Report:Rows (joins duplicate orgs)" do
    report.should_receive(:funders).once.and_return funding_flows
    rows = report.collection
    rows.size.should == 2
    rows.first.class.should == Reports::Row
    rows.first.total_spend.should == BigDecimal.new("500")
    rows.first.total_budget.should == BigDecimal.new("60")
  end

  it "#total_spend" do
    report.should_receive(:direct_rate).twice.and_return 0.5
    report.should_receive(:funders).once.and_return funding_flows
    report.total_spend.should == 650
  end

  it "#total_budget" do
    report.should_receive(:direct_rate).twice.and_return 0.5
    report.should_receive(:funders).once.and_return funding_flows
    report.total_budget.should == 90
  end
end
