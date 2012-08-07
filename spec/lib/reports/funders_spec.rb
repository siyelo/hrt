require 'spec_helper'

describe Reports::Funders do
  let(:organization1) { FactoryGirl.create(:organization, :name => 'organization1') }
  let(:organization2) { FactoryGirl.create(:organization, :name => 'organization2') }

  before :each do
    reporter     = FactoryGirl.create(:reporter, :organization => organization1)
    @data_request  = FactoryGirl.create(:data_request, :organization => organization1)
    @data_response = organization1.latest_response
    @in_flow1     = FactoryGirl.build(:funding_flow, :from => organization1,
                      :budget => 200, :spend => 400)
    @in_flow2     = FactoryGirl.build(:funding_flow, :from => organization2,
                      :budget => 100, :spend => 200)
    @project1     = FactoryGirl.create(:project, :name => 'project1',
                            :data_response => @data_response,
                            :in_flows => [@in_flow1])
    @project2     = FactoryGirl.create(:project, :name => 'project2', #:currency => 'USD',
                            :data_response => @data_response,
                            :in_flows => [@in_flow2])
  end

  it "ignores double counts" do
    @in_flow1.double_count = true
    @in_flow1.save; @project1.reload

    report1 = Reports::Funders.new(@data_request, true)
    report1.collection.first.total_spend.to_f.should == 400

    report1 = Reports::Funders.new(@data_request, false)
    report1.collection.first.total_spend.to_f.should == 200
  end

  describe "report export" do
    it "can export the report in xls format" do
      report = Reports::Funders.new(@data_request, true)
      data = FileParser.parse(report.to_xls, 'xls')

      data[0]["Name"].should == "organization1"
      data[0]["Budget (USD)"].should == 200.0
      data[0]["Expenditure (USD)"].should == 400.0
    end
  end
end
