require 'spec_helper'

describe Reports::ProjectsController do
  context "as a visitor" do
    describe "it should be protected" do
      before :each do get :show, :id => 1 end
      it { should redirect_to(root_url) }
      it { should set_the_flash.to("You must be logged in to access that page") }
    end
  end

  context "as a reporter" do
    let(:project) { mock :project }
    let(:projects) { mock :assoc, :find => project }
    let(:current_response) { mock :response, :projects => projects }

    before :each do
      controller.stub(:current_response).and_return current_response
      @req = FactoryGirl.create :data_request
      @reporter = FactoryGirl.create :reporter
      login @reporter
    end

    it "should render index" do
      Reports::Project.should_receive(:new).with(project).and_return mock(:report)
      get :show, :id => 1
      response.should be_success
      assigns[:report].should_not be_nil
      assigns[:response].should == @reporter.data_responses.first
    end

    it "should initialize an org location presenter" do
      Reports::ProjectLocations.should_receive(:new).with(project).and_return mock(:report)
      get :locations, :id => 1
    end

    it "should initialize an org inputs presenter" do
      Reports::ProjectInputs.should_receive(:new).with(project).and_return mock(:report)
      get :inputs, :id => 1
    end
  end
end
