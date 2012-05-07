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
      @req = Factory :data_request
      @reporter = Factory :reporter
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
      @req = Factory :data_request
      @user = Factory :sysadmin
      login @user
    end

    it "should render index report" do
      get :index
      response.should be_success
      assigns[:report].should_not be_nil
    end

    it "should render index with a Reporter report" do
      pending
      get :index
      assigns[:report].should_not be_nil
    end
  end
end
