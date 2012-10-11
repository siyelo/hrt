require 'spec_helper'

describe Users::SessionsController do

  before :each do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  it "redirects to root path" do
    get :new
    response.should redirect_to(root_path)
  end

  it "shows error if org has no responses (reporter)" do
    user = FactoryGirl.create(:reporter)
    request.env['warden'].stub authenticate: user
    controller.stub current_user: user
    post :create
    user.organization.data_responses.count.should == 0
    flash[:error].should == "Your organization's responses have been removed by a System Administrator. Please <a href='http://hrtapp.tenderapp.com/discussion/new'> contact us </a> for further assistance"
    response.should redirect_to(root_path)
  end

  it "does not show error if org has no responses (sysadmin)" do
    user = FactoryGirl.create(:admin)
    request.env['warden'].stub authenticate: user
    controller.stub current_user: user
    post :create
    user.organization.data_responses.count.should == 0
    flash[:error].should be_nil
    response.should redirect_to(dashboard_path)
  end
end
