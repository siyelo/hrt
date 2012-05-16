require File.dirname(__FILE__) + '/../spec_helper'

describe Reports::DistrictWorkplan do
  before :each do
    currency = Factory(:currency, :from => 'USD', :to => 'RWF', :rate => 2)
    organization1 = Factory(:organization, :name => 'organization1')
    organization2 = Factory(:organization, :name => 'organization2')
    reporter1     = Factory(:reporter, :organization => organization1)
    @data_request  = Factory(:data_request, :organization => organization1)
    data_response = organization1.latest_response
    in_flows      = [Factory.build :funding_flow, :from => organization1,
                      :budget => 100, :spend => 200]
    project1      = Factory(:project, :name => 'project1',
                            :data_response => data_response,
                            :in_flows => in_flows)
    activity1     = Factory(:activity, :name => 'activity1',
                            :data_response => data_response,
                            :project => project1)
    activity2     = Factory(:activity, :name => 'activity2',
                            :data_response => data_response,
                            :project => project1)

    split1        = Factory(:implementer_split, :activity => activity1,
                            :budget => 100, :spend => 200,
                            :organization => organization2)
    split2        = Factory(:implementer_split, :activity => activity2,
                            :budget => 100, :spend => 200,
                            :organization => organization2)
    @district1     = Factory(:location, :short_display => 'district1')
    @district2     = Factory(:location, :short_display => 'district2')
    classifications1 = { @district1.id => 25, @district2.id => 75 }
    CodingBudgetDistrict.update_classifications(activity1, classifications1)
    classifications2 = { @district1.id => 50, @district2.id => 50 }
    CodingSpendDistrict.update_classifications(activity1, classifications2)
    classifications3 = { @district1.id => 25, @district2.id => 75 }
    CodingBudgetDistrict.update_classifications(activity2, classifications3)
    classifications4 = { @district1.id => 50, @district2.id => 50 }
    CodingSpendDistrict.update_classifications(activity2, classifications4)
  end

  it "can generate district workplan" do
    content = Reports::DistrictWorkplan.new(@data_request, @district1, 'xls').data
    rows = FileParser.parse(content, 'xls')

    rows[0]["Partner"].should == 'organization1'
    rows[1]["Partner"].should == nil
    rows[2]["Partner"].should == nil

    rows[0]["Project"].should == 'project1'
    rows[1]["Project"].should == nil
    rows[2]["Project"].should == nil

    rows[0]["Activity"].should == 'activity1'
    rows[1]["Activity"].should == 'activity2'
    rows[2]["Activity"].should == 'Total'

    rows[0]["Expenditure"].should == 200.0
    rows[1]["Expenditure"].should == 200.0
    rows[2]["Expenditure"].should == 400.0

    rows[0]["Budget"].should == 50.0
    rows[1]["Budget"].should == 50.0
    rows[2]["Budget"].should == 100.0

    rows[0]["Implementers"].should == 'organization2'
    rows[1]["Implementers"].should == 'organization2'
    rows[2]["Implementers"].should == nil
  end

  it "can generate district workplan with more than 1 organization" do
    organization3 = Factory(:organization, :name => 'organization3')
    Factory(:reporter, :organization => organization3)
    organization4 = Factory(:organization, :name => 'organization4')
    data_response2 = organization3.latest_response
    in_flows      = [Factory.build :funding_flow, :from => organization3,
                      :budget => 100, :spend => 200]
    project2      = Factory(:project, :name => 'project2',
                            :data_response => data_response2,
                            :in_flows => in_flows)
    activity3     = Factory(:activity, :name => 'activity3',
                            :data_response => data_response2,
                            :project => project2)
    activity4     = Factory(:activity, :name => 'activity4',
                            :data_response => data_response2,
                            :project => project2)
    split3        = Factory(:implementer_split, :activity => activity3,
                            :budget => 100, :spend => 200,
                            :organization => organization4)
    split4        = Factory(:implementer_split, :activity => activity4,
                            :budget => 100, :spend => 200,
                            :organization => organization4)
    classifications1 = { @district1.id => 25, @district2.id => 75 }
    CodingBudgetDistrict.update_classifications(activity3, classifications1)
    classifications2 = { @district1.id => 50, @district2.id => 50 }
    CodingSpendDistrict.update_classifications(activity3, classifications2)
    classifications3 = { @district1.id => 25, @district2.id => 75 }
    CodingBudgetDistrict.update_classifications(activity4, classifications3)
    classifications4 = { @district1.id => 50, @district2.id => 50 }
    CodingSpendDistrict.update_classifications(activity4, classifications4)

    xls = Reports::DistrictWorkplan.new(@data_request, @district1, 'xls').data
    rows = Spreadsheet.open(StringIO.new(xls)).worksheet(0)
    rows.row(4).to_a.should == ['organization3', 'project2', 'activity3',
                                 200.0, 50.0, 'organization4']
    rows.row(5).to_a.should == [nil, nil, 'activity4',
                                 200.0, 50.0, 'organization4']
    rows.row(6).to_a.should == [nil, nil, 'Total',
                                 400.0, 100.0, nil]
  end

end
