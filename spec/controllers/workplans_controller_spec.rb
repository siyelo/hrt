require 'spec_helper'

include ControllerStubs

describe WorkplansController do
  context "activity manager" do
    before :each do
      basic_setup_response_for_controller
      @user.roles = ['activity_manager']
      @user.save!
      login @user
      request.env["HTTP_REFERER"] = '/'
    end

    it "allows Activity Manager to download the combined workplan" do
      @user.stub(:workplan).and_return true
      @user.stub(:workplan_private_url).and_return('/')
      get :download
      response.should be_redirect
    end

    it "allows Activity Manager to generate the combined workplan" do
      get :generate
      response.should be_redirect
      flash[:notice].should == "We are generating your combined workplan and will send you an email (at #{@user.email}) when it is ready."

      unread_emails_for(@user.email).size.should == 1
      open_email(@user.email).body.should include('We have generated the combined workplan for you')
    end
  end

  it "does not allow other users to download the Activity Manager's combined workplan" do
    user = stub_logged_in_reporter
    user.stub_chain(:organization, :data_responses,
                    :latest_first, :first).and_return(@data_response)
    get :download
    response.should redirect_to(root_url)
    flash[:error].should == "You must be an activity manager to access that page"
  end
end
