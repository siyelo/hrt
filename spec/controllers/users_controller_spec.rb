require File.dirname(__FILE__) + '/../spec_helper'

include ControllerStubs

describe UsersController do
  [:sysadmin, :reporter, :activity_manager].each do |user|
    it "can set the #{user.to_s.humanize}'s request" do
      @organization  = Factory(:organization)
      @data_request  = Factory(:data_request, :organization => @organization)
      @data_response = @organization.latest_response
      @user = Factory(user, :organization => @organization)
      login @user
      @data_response = @organization.latest_response
      @request.env['HTTP_REFERER'] = 'http://test.com/dashboard'
      put :set_request, :id => @data_request.id
      response.should redirect_to('http://test.com/dashboard')
      @user.reload
      @user.current_request.should == @data_request
    end
  end

  [:sysadmin, :reporter, :activity_manager].each do |user|
    it "can switch response for #{user.to_s.humanize}" do
      @organization  = Factory(:organization)
      @data_request1  = Factory(:data_request, :organization => @organization)
      @data_response1 = @organization.latest_response
      @data_request2  = Factory(:data_request, :organization => @organization)
      @data_response2 = @organization.latest_response
      @user = Factory(user, :organization => @organization)
      login @user
      @request.env['HTTP_REFERER'] = response_projects_path(@data_response2)
      put :set_request, :id => @data_request1.id
      response.should redirect_to(response_projects_path(@data_response1))
      @user.reload
      @user.current_request.should == @data_request1
    end
  end

  it "allows Activity Manager to download the combined workplan" do
    @organization = Factory :organization, :name => "Organization"
    @user = Factory.create(:activity_manager, :organization => @organization)
    @organization = @user.organization
    login @user
    get :activity_manager_workplan
    response.should be_success
    response.header["Content-Type"].should == "application/excel"
    response.header["Content-Disposition"].should == "attachment; filename=combined_workplan.xls"
  end

  it "does not allow other users to download the Activity Manager's combined workplan" do
    user = stub_logged_in_reporter
    user.stub_chain(:data_responses, :find).and_return(@data_response)
    get :activity_manager_workplan
    response.should redirect_to(root_url)
    flash[:error].should == "You must be an activity manager to access that page"
  end
end
