require File.dirname(__FILE__) + '/../spec_helper_lite'

$: << File.join(APP_ROOT, "app/reports")

require 'app/reports/reporters'

describe Reports::Reporters do
  let(:response1) { mock :response,
    :total_spend => 100, :total_budget => 20, :name => 'response1', :currency => 'USD' }
  let(:response2) { mock :response,
    :total_spend => 400, :total_budget => 40, :name => 'response2', :currency => 'USD' }
  let(:response3) { mock :response,
    :total_spend => 300, :total_budget => 60, :name => 'response3', :currency => 'USD' }
  let(:responses) { [response1, response2, response3] }

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
    report.should_receive(:responses).once.and_return responses
    report.total_spend.should == 800
  end

  it "#total_budget" do
    report.should_receive(:responses).once.and_return responses
    report.total_budget.should == 120
  end

  it "#collection is made up of responses" do
    report.should_receive(:responses).once.and_return responses
    report.collection.should == responses
  end
end
