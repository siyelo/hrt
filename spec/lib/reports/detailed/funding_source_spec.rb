require 'spec_helper'

describe Reports::Detailed::FundingSource do
  def run_report
    content = Reports::Detailed::FundingSource.new(@request, 'xls').data
    FileParser.parse(content, 'xls')
  end

  context "simple report" do
    before :each do
      @request = FactoryGirl.create :data_request
      @donor = FactoryGirl.create(:organization)
      @organization = FactoryGirl.create(:organization)
      FactoryGirl.create :user, :organization => @organization
      @response     = @organization.latest_response
      @project      = FactoryGirl.create(:project,
                              :data_response => @response)
      @project.in_flows = [FactoryGirl.create(:funding_flow, :project => @project,
                                   :from => @donor)]
      @response.state = 'accepted'; @response.save
    end

    it "should return a 1 funder report" do
      @project.budget_type = 'on'
      @project.save
      table = run_report
      table[0]['Funding Source'].should == @project.in_flows.first.from.name
      table[0]['Organization'].should == @organization.try(:name)
      table[0]['Project'].should == @project.try(:name)
      table[0]['On/Off Budget'].should == 'on'
      table[0]['Planned Disbursement'].should == 90.00
      table[0]['Disbursement Received'].should == 100.00
      table[0]['Possible Funder Double-Count?'].should == false
    end

    context "multiflow reports" do
      before :each do
        @donor1 = FactoryGirl.create(:organization, :name => "dony")
        @organization1 = FactoryGirl.create(:organization, :name => "orgy")
        FactoryGirl.create :user, :organization => @organization1
        @response1     = @organization1.latest_response
        @response1.state = 'accepted'; @response1.save
        @project1      = FactoryGirl.create(:project, :data_response => @response1, :name => "CoolProject")
        @project1.in_flows = [FactoryGirl.create(:funding_flow, :project => @project1,
                                      :from => @donor1, :spend => 99, :budget => 98)]
      end

      it "should properly convert currencies" do
        @currency = FactoryGirl.create(:currency, :from => 'RWF', :to => 'USD', :rate => 0.5)
        @project1.currency = "RWF"; @project1.save

        table = run_report
        table[0]['Funding Source'].should == @project.in_flows.first.from.name
        table[0]['Organization'].should == @organization.name
        table[0]['Project'].should == @project.name
        table[0]['Planned Disbursement'].should == 90.00
        table[0]['Disbursement Received'].should == 100.00

        table[1]['Funding Source'].should == @donor1.name
        table[1]['Organization'].should == "orgy"
        table[1]['Project'].should == "CoolProject"
        table[1]['Planned Disbursement'].should == 49.00
        table[1]['Disbursement Received'].should == 49.50
      end

      it "should return a 2 funder report" do
        table = run_report
        table[0]['Funding Source'].should == @project.in_flows.first.from.name
        table[0]['Organization'].should == @organization.name
        table[0]['Project'].should == @project.name
        table[0]['Planned Disbursement'].should == 90.00
        table[0]['Disbursement Received'].should == 100.00

        table[1]['Funding Source'].should == @donor1.name
        table[1]['Organization'].should == "orgy"
        table[1]['Project'].should == "CoolProject"
        table[1]['Planned Disbursement'].should == 98.00
        table[1]['Disbursement Received'].should == 99.00
      end
    end
  end
end

