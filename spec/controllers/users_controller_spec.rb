require 'spec_helper'

include ControllerStubs

describe UsersController do
  it "allows Activity Manager to download the combined workplan" do
    basic_setup_response_for_controller
    @user.roles = ['activity_manager']
    @user.save!
    login @user
    get :activity_manager_workplan
    response.should be_success
    response.header["Content-Type"].should == "application/vnd.ms-excel"
    response.header["Content-Disposition"].should == "attachment; filename=combined_workplan.xls"
  end

  it "does not allow other users to download the Activity Manager's combined workplan" do
    user = stub_logged_in_reporter
    user.stub_chain(:organization, :data_responses,
                    :latest_first, :first).and_return(@data_response)
    get :activity_manager_workplan
    response.should redirect_to(root_url)
    flash[:error].should == "You must be an activity manager to access that page"
  end
end
