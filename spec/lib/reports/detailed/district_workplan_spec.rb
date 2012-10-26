require 'spec_helper'

describe Reports::Detailed::DistrictWorkplan do
  before :each do
    currency = FactoryGirl.create(:currency, from: 'RWF', to: 'USD', rate: 2)
    organization1 = FactoryGirl.create(:organization, name: 'organization1', currency: 'RWF')
    organization2 = FactoryGirl.create(:organization, name: 'organization2', currency: 'RWF')
    reporter1     = FactoryGirl.create(:reporter, organization: organization1)
    @data_request  = FactoryGirl.create(:data_request, organization: organization1)
    data_response = organization1.latest_response
    in_flows      = [FactoryGirl.build(:funding_flow, from: organization1,
                      budget: 100, spend: 200)]
    project1      = FactoryGirl.create(:project, name: 'project1',
                            data_response: data_response,
                            in_flows: in_flows,
                            currency: 'RWF')
    activity1     = FactoryGirl.create(:activity, name: 'activity1',
                            data_response: data_response,
                            project: project1)
    activity2     = FactoryGirl.create(:activity, name: 'activity2',
                            data_response: data_response,
                            project: project1)

    split1        = FactoryGirl.create(:implementer_split, activity: activity1,
                            budget: 100, spend: 200,
                            organization: organization2)
    split2        = FactoryGirl.create(:implementer_split, activity: activity2,
                            budget: 100, spend: 200,
                            organization: organization2)
    @district1     = FactoryGirl.create(:location, name: 'district1')
    @district2     = FactoryGirl.create(:location, name: 'district2')
    activity1.stub_chain(:data_request, :locations_version).and_return(1)
    activity2.stub_chain(:data_request, :locations_version).and_return(1)
    activity1.reload
    activity2.reload
    classifications1 = { @district1.id => 25, @district2.id => 75 }
    LocationBudgetSplit.update_classifications(activity1, classifications1)
    classifications2 = { @district1.id => 50, @district2.id => 50 }
    LocationSpendSplit.update_classifications(activity1, classifications2)
    classifications3 = { @district1.id => 25, @district2.id => 75 }
    LocationBudgetSplit.update_classifications(activity2, classifications3)
    classifications4 = { @district1.id => 50, @district2.id => 50 }
    LocationSpendSplit.update_classifications(activity2, classifications4)
  end

  it "can generate district workplan" do
    content = Reports::Detailed::DistrictWorkplan.new(
      @data_request, @district1, true, 'xls').data
    rows = FileParser.parse(content, 'xls')

    rows[0]["Partner"].should == 'organization1'
    rows[1]["Partner"].should == nil
    rows[2]["Partner"].should == nil

    rows[0]["Project"].should == 'project1'
    rows[1]["Project"].should == nil
    rows[2]["Project"].should == nil

    rows[0]["Activity"].should == 'activity1'
    rows[1]["Activity"].should == 'activity2'
    rows[2]["Activity"].should == nil

    rows[0]["Implementer"].should == 'organization2'
    rows[1]["Implementer"].should == 'organization2'
    rows[2]["Implementer"].should == 'Total'

    rows[0]["Expenditure (USD)"].should == 200.0
    rows[1]["Expenditure (USD)"].should == 200.0
    rows[2]["Expenditure (USD)"].should == 400.0

    rows[0]["Budget (USD)"].should == 50.0
    rows[1]["Budget (USD)"].should == 50.0
    rows[2]["Budget (USD)"].should == 100.0
  end

  context "multiple organizations" do
    before :each do
      organization3 = FactoryGirl.create(:organization, name: 'organization3', currency: 'RWF')
      organization4 = FactoryGirl.create(:organization, name: 'organization4', currency: 'RWF')
      organization5 = FactoryGirl.create(:organization, name: 'organization5', currency: 'RWF')

      FactoryGirl.create(:reporter, organization: organization3)
      data_response2 = organization3.latest_response

      in_flows      = [FactoryGirl.build(:funding_flow, from: organization3,
                        budget: 100, spend: 200)]

      project2      = FactoryGirl.create(:project, name: 'project2',
                              data_response: data_response2,
                              in_flows: in_flows, currency: 'RWF')

      activity3     = FactoryGirl.create(:activity, name: 'activity3',
                              data_response: data_response2,
                              project: project2)
      activity4     = FactoryGirl.create(:activity, name: 'activity4',
                              data_response: data_response2,
                              project: project2)
      FactoryGirl.create(:implementer_split, activity: activity3,
                         budget: 50, spend: 100, organization: organization3,
                         double_count: true)
      FactoryGirl.create(:implementer_split, activity: activity3,
                         budget: 50, spend: 100, organization: organization4)
      FactoryGirl.create(:implementer_split, activity: activity3,
                         budget: 50, spend: 100, organization: organization5,
                         double_count: true)
      FactoryGirl.create(:implementer_split, activity: activity4,
                         budget: 100, spend: 200, organization: organization4)
      FactoryGirl.create(:implementer_split, activity: activity4,
                         budget: 100, spend: 200, organization: organization3)

      activity3.stub_chain(:data_request, :locations_version).and_return(1)
      activity4.stub_chain(:data_request, :locations_version).and_return(1)
      activity3.reload
      activity4.reload

      classifications1 = { @district1.id => 25, @district2.id => 75 }
      LocationBudgetSplit.update_classifications(activity3, classifications1)
      classifications2 = { @district1.id => 50, @district2.id => 50 }
      LocationSpendSplit.update_classifications(activity3, classifications2)
      classifications3 = { @district1.id => 25, @district2.id => 75 }
      LocationBudgetSplit.update_classifications(activity4, classifications3)
      classifications4 = { @district1.id => 50, @district2.id => 50 }
      LocationSpendSplit.update_classifications(activity4, classifications4)
    end

    it "including double counts" do
      xls = Reports::Detailed::DistrictWorkplan.new(
        @data_request, @district1, true, 'xls').data
      rows = Spreadsheet.open(StringIO.new(xls)).worksheet(0)
      rows.row(4).to_a.should == ['organization3', 'project2', 'activity3',
                                  'organization3, organization4, organization5',
                                  300.0, 75.0]
      rows.row(5).to_a.should == [nil, nil, 'activity4',
                                  'organization3, organization4', 400.0, 100.0]
      rows.row(6).to_a.should == [nil, nil, nil, 'Total', 700.0, 175.0]
    end

    it "excludes double counts" do
      xls = Reports::Detailed::DistrictWorkplan.new(
        @data_request, @district1, false, 'xls').data
      rows = Spreadsheet.open(StringIO.new(xls)).worksheet(0)
      rows.row(4).to_a.should == ['organization3', 'project2', 'activity3',
                                  'organization4', 100.0, 25.0]
      rows.row(5).to_a.should == [nil, nil, 'activity4',
                                  'organization3, organization4', 400.0, 100.0]
      rows.row(6).to_a.should == [nil, nil, nil, 'Total', 500.0, 125.0]
    end
  end

end
