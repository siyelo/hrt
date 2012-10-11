require 'spec_helper'

describe Admin::ReportsController do

  describe "user permissions" do
    before :each do
      login # login as reporter
    end

    it_should_require_sysadmin_for :index, :reporters, :funders, :locations,
                                   :district_workplan
  end

  describe "actions" do
    before :each do
      @req = FactoryGirl.create :data_request
      @user = FactoryGirl.create :sysadmin
      login @user
    end

    describe "index" do
      it "should render index report" do
        get :index
        response.should be_success
        assigns[:report].should_not be_nil
      end
    end

    [:reporters, :funders, :locations].each do |report_type|
      describe "#{report_type}" do
        it "should render #{report_type} report with double counts" do
          get report_type, double_count: 'false'
          response.should be_success
          assigns[:report].include_double_count.should be_false
          assigns[:report].should_not be_nil
        end

        it "should render #{report_type} report without double counts" do
          get report_type, double_count: 'true'
          response.should be_success
          assigns[:report].include_double_count.should be_true
          assigns[:report].should_not be_nil
        end

        it "can download #{report_type} report with double counts included" do
          get report_type, double_count: 'true', format: 'xls'
          response.should be_success
          assigns[:report].include_double_count.should be_true
          response.header["Content-Type"].should == "application/vnd.ms-excel"
          response.header["Content-Disposition"].should ==
            "attachment; filename=#{report_type}_double_counts_included.xls"
        end

        it "can download #{report_type} report" do
          get report_type, double_count: 'false', format: 'xls'
          response.should be_success
          assigns[:report].include_double_count.should be_false
          response.header["Content-Type"].should == "application/vnd.ms-excel"
          response.header["Content-Disposition"].should ==
            "attachment; filename=#{report_type}_double_counts_excluded.xls"
        end
      end
    end

    describe "district_workplan" do
      it "downloads xls district report" do
        location = mock_model(Location)
        location.stub(:name).and_return('district1')
        Location.stub(:find_by_name).and_return(location)
        get :district_workplan, id: 1
        response.should be_success
        response.header["Content-Type"].should == "application/vnd.ms-excel"
        response.header["Content-Disposition"].should ==
          "attachment; filename=district1_district_workplan_without_double_counts.xls"
      end

      it "downloads xls district report" do
        Location.stub(:find).and_return(nil)
        get :district_workplan, id: 1
        response.should redirect_to(locations_admin_reports_path)
      end
    end
  end
end
