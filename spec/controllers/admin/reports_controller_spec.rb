require 'spec_helper'

describe Admin::ReportsController do
  context "as a visitor" do
    describe "#index" do
      before :each do get :index end
      it { should redirect_to(root_url) }
      it { should set_the_flash.to("You must be an administrator to access that page") }
    end
  end

  context "as a reporter" do
    before :each do
      @req = FactoryGirl.create :data_request
      @reporter = FactoryGirl.create :reporter
      login @reporter
    end

    describe "#index" do
      before :each do get :index end
      it { should redirect_to(root_url) }
      it { should set_the_flash.to("You must be an administrator to access that page") }
    end
  end

  context "as an admin" do
    before :each do
      @req = FactoryGirl.create :data_request
      @user = FactoryGirl.create :sysadmin
      login @user
    end

    it "should render index report" do
      get :index
      response.should be_success
      assigns[:report].should_not be_nil
    end

    it "downloads xls district report" do
      location = mock_model(Location)
      location.stub(:short_display).and_return('district1')
      Location.stub(:find_by_short_display).and_return(location)
      get :district_workplan, :id => 1
      response.should be_success
      response.header["Content-Type"].should == "application/vnd.ms-excel"
      response.header["Content-Disposition"].should ==
        "attachment; filename=district1_district_workplan.xls"
    end

    it "downloads xls district report" do
      Location.stub(:find).and_return(nil)
      get :district_workplan, :id => 1
      response.should redirect_to(locations_admin_reports_path)
    end
  end
end
