require 'spec_helper'

describe Reports::Funders do
  let(:organization1) { FactoryGirl.create(:organization, :name => 'organization1') }
  let(:organization2) { FactoryGirl.create(:organization, :name => 'organization2') }

  before :each do
    #currency = FactoryGirl.create(:currency, :from => 'USD', :to => 'RWF', :rate => 2)
    reporter     = FactoryGirl.create(:reporter, :organization => organization1)
    @data_request  = FactoryGirl.create(:data_request, :organization => organization1)
    @data_response = organization1.latest_response
    in_flows1     = [FactoryGirl.build(:funding_flow, :from => organization1,
                      :budget => 100, :spend => 200)]
    in_flows2     = [FactoryGirl.build(:funding_flow, :from => organization2,
                      :budget => 200, :spend => 400)]
    @project1      = FactoryGirl.create(:project, :name => 'project1',
                            :data_response => @data_response,
                            :in_flows => in_flows1)
    @project2      = FactoryGirl.create(:project, :name => 'project2', #:currency => 'USD',
                            :data_response => @data_response,
                            :in_flows => in_flows2)
  end

  context "when implementer splits exist" do
    before :each do
      split11       = FactoryGirl.build(:implementer_split,
                              :budget => 100, :spend => 200,
                              :double_count => false,
                              :organization => organization1)
      split12       = FactoryGirl.build(:implementer_split,
                              :budget => 100, :spend => 200,
                              :double_count => true,
                              :organization => organization2)
      split21       = FactoryGirl.build(:implementer_split,
                              :budget => 200, :spend => 400,
                              :double_count => false,
                              :organization => organization1)
      split22       = FactoryGirl.build(:implementer_split,
                              :budget => 600, :spend => 1200,
                              :double_count => true,
                              :organization => organization2)
      activity1     = FactoryGirl.create(:activity, :name => 'activity1',
                              :data_response => @data_response,
                              :implementer_splits => [split11, split12],
                              :project => @project1)
      activity2     = FactoryGirl.create(:activity, :name => 'activity2',
                              :data_response => @data_response,
                              :implementer_splits => [split21, split22],
                              :project => @project2)
    end

    it "generates report with double counts" do
      report = Reports::Funders.new(@data_request, true)
      collection = report.collection
      org1_row = collection.detect{ |row| row.name == organization1.name }
      org2_row = collection.detect{ |row| row.name == organization2.name }

      org1_row.total_budget.should == 100
      org1_row.total_spend.should == 200

      org2_row.total_budget.should == 200
      org2_row.total_spend.should == 400
    end

    it "generates report without double counts" do
      report = Reports::Funders.new(@data_request, false)
      collection = report.collection
      org1_row = collection.detect{ |row| row.name == organization1.name }
      org2_row = collection.detect{ |row| row.name == organization2.name }

      # 50% double counts
      org1_row.total_budget.should == 50
      org1_row.total_spend.should == 100

      # 75% double counts
      org2_row.total_budget.should == 50
      org2_row.total_spend.should == 100
    end
  end

  context "when implementer splits does not exist" do
    it "generates report with double counts" do
      report = Reports::Funders.new(@data_request, true)
      collection = report.collection
      org1_row = collection.detect{ |row| row.name == organization1.name }
      org2_row = collection.detect{ |row| row.name == organization2.name }

      org1_row.total_budget.should == 100
      org1_row.total_spend.should == 200

      org2_row.total_budget.should == 200
      org2_row.total_spend.should == 400
    end

    it "generates report without double counts" do
      report = Reports::Funders.new(@data_request, false)
      collection = report.collection
      org1_row = collection.detect{ |row| row.name == organization1.name }
      org2_row = collection.detect{ |row| row.name == organization2.name }

      org1_row.total_budget.should == 100
      org1_row.total_spend.should == 200

      org2_row.total_budget.should == 200
      org2_row.total_spend.should == 400
    end
  end
end
