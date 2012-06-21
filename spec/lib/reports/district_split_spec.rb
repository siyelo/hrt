require 'spec_helper'

describe Reports::DistrictSplit do
  before :each do
    #currency = FactoryGirl.create(:currency, :from => 'USD', :to => 'RWF', :rate => 2)
    organization1 = FactoryGirl.create(:organization, :name => 'organization1')
    organization2 = FactoryGirl.create(:organization, :name => 'organization2')
    reporter1     = FactoryGirl.create(:reporter, :organization => organization1)
    @data_request  = FactoryGirl.create(:data_request, :organization => organization1)
    data_response = organization1.latest_response
    in_flows1     = [FactoryGirl.build(:funding_flow, :from => organization1,
                      :budget => 100, :spend => 200)]
    in_flows2     = [FactoryGirl.build(:funding_flow, :from => organization1,
                      :budget => 200, :spend => 400)]
    project1      = FactoryGirl.create(:project, :name => 'project1',
                            :data_response => data_response,
                            :in_flows => in_flows1)
    project2      = FactoryGirl.create(:project, :name => 'project2', #:currency => 'USD',
                            :data_response => data_response,
                            :in_flows => in_flows2)
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
                            :budget => 200, :spend => 400,
                            :double_count => true,
                            :organization => organization2)
    activity1     = FactoryGirl.create(:activity, :name => 'activity1',
                            :data_response => data_response,
                            :implementer_splits => [split11, split12],
                            :project => project1)
    activity2     = FactoryGirl.create(:activity, :name => 'activity2',
                            :data_response => data_response,
                            :implementer_splits => [split21, split22],
                            :project => project2)
    district1     = FactoryGirl.create(:location, :short_display => 'district1')
    district2     = FactoryGirl.create(:location, :short_display => 'district2')

    classifications1 = { district1.id => 25, district2.id => 75 } #budget
    LocationBudgetSplit.update_classifications(activity1, classifications1)
    classifications2 = { district1.id => 50, district2.id => 50 } #spend
    LocationSpendSplit.update_classifications(activity1, classifications2)
    classifications3 = { district1.id => 35, district2.id => 65 } #budget
    LocationBudgetSplit.update_classifications(activity2, classifications3)
    classifications4 = { district1.id => 40, district2.id => 60 } #spend
    LocationSpendSplit.update_classifications(activity2, classifications4)
  end

  it "generates report with double counts" do
    report = Reports::DistrictSplit.new(@data_request, true)
    collection = report.collection
    collection[0].total_budget.to_f.should == 190.0 # district1 (100*25% + 200*35%) * 2
    collection[0].total_spend.to_f.should  == 520.0 # district1 (200*50% + 400*40%) * 2
    collection[1].total_budget.to_f.should == 410.0 # district2 (100*75% + 200*65%) * 2
    collection[1].total_spend.to_f.should  == 680.0 # district2 (200*50% + 400*60%) * 2
  end

  it "generates report without double counts" do
    report = Reports::DistrictSplit.new(@data_request, false)
    collection = report.collection
    collection[0].total_budget.to_f.should == 95.0 # district1 (100*25% + 200*35%)
    collection[0].total_spend.to_f.should  == 260.0 # district1 (200*50% + 400*40%)
    collection[1].total_budget.to_f.should == 205.0 # district2 (100*75% + 200*65%)
    collection[1].total_spend.to_f.should  == 340.0 # district2 (200*50% + 400*60%)
  end
end
