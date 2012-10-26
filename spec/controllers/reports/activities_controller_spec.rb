require 'spec_helper'

describe Reports::ActivitiesController do
  context "as a visitor" do
    describe "it should be protected" do
      before :each do get :show, id: 1 end
      it { should redirect_to(root_url) }
      it { should set_the_flash.to("You must be logged in to access that page") }
    end
  end

  context "as a reporter" do
    let(:activity) { mock :activity }
    let(:report) { mock :report, to_xls: [], name: 'speccin' }
    let(:current_response) { mock :response }

    before :each do
      controller.stub(:load_activity).and_return activity
      @req = FactoryGirl.create :data_request
      @reporter = FactoryGirl.create :reporter
      login @reporter
    end

    it "should render index" do
      Reports::Activity.should_receive(:new).with(activity).and_return mock(:report)
      get :show, id: 1
      response.should be_success
      assigns[:report].should_not be_nil
      assigns[:response].should == @reporter.data_responses.first
    end

    it "should initialize a location presenter" do
      Reports::ActivityLocations.should_receive(:new).with(activity).and_return mock(:report)
      get :locations, id: 1
    end

    it "should initialize an inputs presenter" do
      Reports::ActivityInputs.should_receive(:new).with(activity).and_return mock(:report)
      get :inputs, id: 1
    end

    it "allows exporting of implementers report" do
      Reports::Activity.should_receive(:new).with(activity).and_return report
      get :implementers, format: 'xls', id: 1
      response.should be_success
      response.header["Content-Type"].should == "application/vnd.ms-excel"
      response.header["Content-Disposition"].should ==
        "attachment; filename=speccin-implementers.xls"
    end
  end
end
