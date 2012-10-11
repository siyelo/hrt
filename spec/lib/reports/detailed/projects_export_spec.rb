require 'spec_helper'

describe Reports::Detailed::ProjectsExport do
  describe "export projects and activities to xls" do
    it "returns xls with blank cells for repeated project & activity" do
      basic_setup_implementer_split
      split = @split
      split2 = FactoryGirl.create(:implementer_split, activity: @activity,
                       organization: @organization)
      other_cost = FactoryGirl.create(:other_cost, name: 'other cost',
                           project: nil, data_response: @response)
      split3 = FactoryGirl.create(:implementer_split, activity: other_cost,
                       organization: @organization)

      @activity.save!
      @project.budget_type = "on"
      @project.save

      xls = Reports::Detailed::ProjectsExport.new(@response, 'xls').data
      rows = Spreadsheet.open(StringIO.new(xls)).worksheet(0)
      rows.row(0).should == Reports::Detailed::ProjectsExport::FILE_UPLOAD_COLUMNS
      rows[1,0].should == @project.name
      rows[1,1].should == "on"
      rows[1,2].should == @project.description
      rows[1,3].should == @project.start_date.to_s
      rows[1,4].should == @project.end_date.to_s
      rows[1,5].should == @activity.name
      rows[1,6].should == @activity.description
      rows[1,7].should == split.id
      rows[1,8].should == split.organization_name
      rows[1,9].should == split.spend.to_f
      rows[1,10].should == split.budget.to_f

      rows[2,0].should == nil
      rows[2,1].should == nil
      rows[2,2].should == nil
      rows[2,3].should == nil
      rows[2,4].should == nil
      rows[2,5].should == nil
      rows[2,6].should == nil
      rows[2,7].should == split2.id
      rows[2,8].should == split2.organization_name
      rows[2,9].should == split2.spend.to_f
      rows[2,10].should == split2.budget.to_f

      rows[3,0].should == 'N/A'
      rows[3,1].should == 'N/A'
      rows[3,2].should == 'N/A'
      rows[3,3].should == 'N/A'
      rows[3,4].should == 'N/A'
      rows[3,5].should == other_cost.name
      rows[3,6].should == other_cost.description
      rows[3,7].should == split3.id
      rows[3,8].should == split3.organization_name
      rows[3,9].should == split3.spend.to_f
      rows[3,10].should == split3.budget.to_f
    end
  end
end
