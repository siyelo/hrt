require 'spec_helper'

describe Reports::Reporters do
  let(:response1) { mock :response,
                    :spend => 100, :budget => 20, :org_name => 'two',
                    :amount_currency => 'USD' }
  let(:response2) { mock :response,
                    :spend => 400, :budget => 40, :org_name => 'two',
                    :amount_currency => 'USD' }
  let(:response3) { mock :response,
                    :spend => 300, :budget => 60, :org_name => 'three',
                    :amount_currency => 'USD' }
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

  it "#collection is made up of Report::Row objects (joins duplicate organizations)" do
    report.should_receive(:rows).once.and_return responses
    rows = report.collection
    rows.size.should == 2
    rows.first.class.should == Reports::Row
    rows.first.total_spend.should == BigDecimal.new("500")
    rows.first.total_budget.should == BigDecimal.new("60")
  end

  it "orders the spend chart" do
    expected = rows
    Charts::Spend.should_receive(:new).once.with(expected).
      and_return(mock(:column, :google_column => ""))
    report.should_receive(:create_rows).once.and_return rows
    report.expenditure_chart
  end

  it "orders the budget chart" do
    expected = rows.reverse
    Charts::Budget.should_receive(:new).once.with(expected).
      and_return(mock(:column, :google_column => ""))
    report.should_receive(:create_rows).once.and_return rows
    report.budget_chart
  end

  it "uses the same colours" do
    report.should_receive(:create_rows).once.and_return rows
    report.budget_colours.should ==
      "{\"0\":{\"color\":\"#dc3912\"},\"1\":{\"color\":\"#3366cc\"}}"
    report.expenditure_colours.should ==
      "{\"0\":{\"color\":\"#3366cc\"},\"1\":{\"color\":\"#dc3912\"}}"
  end

  it "ignores double counts" do
    organization1 = FactoryGirl.create(:organization, :name => 'organization1')
    organization2 = FactoryGirl.create(:organization, :name => 'organization2')
    reporter1     = FactoryGirl.create(:reporter, :organization => organization1)
    data_request  = FactoryGirl.create(:data_request, :organization => organization1)
    data_response = organization1.latest_response
    project1      = FactoryGirl.create(:project, :name => 'project1',
                            :data_response => data_response)
    activity1     = FactoryGirl.create(:activity, :name => 'activity1',
                            :data_response => data_response,
                            :project => project1)
    split1        = FactoryGirl.create(:implementer_split, :activity => activity1,
                            :budget => 100, :spend => 200,
                            :organization => organization2, :double_count => true)
    split2        = FactoryGirl.create(:implementer_split, :activity => activity1,
                            :budget => 100, :spend => 200,
                            :organization => organization2, :double_count => nil)
    activity1.reload

    report1 = Reports::Reporters.new(data_request, true)
    report1.collection.first.total_spend.to_f.should == 400

    report1 = Reports::Reporters.new(data_request, false)
    report1.collection.first.total_spend.to_f.should == 200
  end

  describe "report export" do
    it "can export the report in xls format" do
      organization1 = FactoryGirl.create(:organization, :name => 'organization1')
      reporter1     = FactoryGirl.create(:reporter, :organization => organization1)
      data_request  = FactoryGirl.create(:data_request, :organization => organization1)
      data_response = organization1.latest_response
      project1      = FactoryGirl.create(:project, :name => 'project1',
                              :data_response => data_response)
      split1        = FactoryGirl.create(:implementer_split,
                              :budget => 100, :spend => 200,
                              :organization => organization1)
      activity1     = FactoryGirl.create(:activity, :name => 'activity1',
                              :implementer_splits => [split1],
                              :data_response => data_response,
                              :project => project1)

      report = Reports::Reporters.new(data_request, true)
      # report.collection.first.total_spend.to_f.should == 400

      data = FileParser.parse(report.to_xls, 'xls')

      data[0]["Name"].should == "organization1"
      data[0]["Budget (USD)"].should == 100.0
      data[0]["Expenditure (USD)"].should == 200.0
    end
  end
end
