require 'spec_helper'

describe ReportsController do
  let(:current_response) { mock :response }

  before :each do
    controller.stub(:current_response).and_return current_response
  end

  context "protection" do
    describe "#index" do
      before :each do get :index end
      it { should redirect_to(root_url) }
      it { should set_the_flash.to("You must be logged in to access that page") }
    end

    describe "#inputs" do
      before :each do get :inputs end
      it { should redirect_to(root_url) }
      it { should set_the_flash.to("You must be logged in to access that page") }
    end

    describe "#locations" do
      before :each do get :locations end
      it { should redirect_to(root_url) }
      it { should set_the_flash.to("You must be logged in to access that page") }
    end
  end

  context "as a reporter" do
    before :each do
      @req = FactoryGirl.create :data_request
      @reporter = FactoryGirl.create :reporter
      login @reporter
    end

    it "should render index" do
      Reports::Organization.should_receive(:new).with(current_response).and_return mock(:report)
      get :index
      response.should be_success
      assigns[:report].should_not be_nil
      assigns[:response].should == @reporter.data_responses.first
    end

    it "should initialize an org location presenter" do
      Reports::OrganizationLocations.should_receive(:new).with(current_response).and_return mock(:report)
      get :locations
    end

    it "should initialize an org inputs presenter" do
      Reports::OrganizationInputs.should_receive(:new).with(current_response).and_return mock(:report)
      get :inputs
    end
  end
end
