require 'spec_helper'

describe Admin::ResponsesController do
  describe "index" do
    before :each do
      login_as_admin
      pie = mock :chart, :google_bar => {}
      Charts::Responses::State.should_receive(:new).once.and_return pie
      # login as admin creates 1 NR and 1 Reporting org(1 response)
      @data_response = @admin_org.responses.first
      @request1 = Factory(:data_request) # autocreate 1 response for first reporting org
      @org = Factory(:organization)
      Factory :user, :organization => @org #+2 responses
      @latest_response = @org.responses.latest_first.first
    end

    it "should return all responses for current request by default" do
      get :index
      assigns(:responses).size.should == 2
    end

    it "should return all responses" do
      get :index, :filter => 'All'
      assigns(:responses).size.should == 2
    end

    it "should ignore unrecognized filters" do
      get :index, :filter => 'Blah'
      assigns(:responses).size.should == 2
    end

    it "should filter by empty response" do
      get :index, :filter => 'Not Started'
      assigns(:responses).size.should == 2
    end

    it "should filter by started response" do
      @latest_response.state = 'started'
      @latest_response.save!
      get :index, :filter => 'Started'
      assigns(:responses).size.should == 1
    end

    it "should filter by rejected response" do
      @latest_response.state = 'rejected'
      @latest_response.save!
      get :index, :filter => 'Rejected'
      assigns(:responses).size.should == 1
    end

    it "should filter by submitted response" do
      @latest_response.state = 'submitted'
      @latest_response.save!
      get :index, :filter => 'Submitted'
      assigns(:responses).size.should == 1
    end

    it "should filter by complete response" do
      @latest_response.state = 'accepted'
      @latest_response.save!
      get :index, :filter => 'Accepted'
      assigns(:responses).size.should == 1
    end
  end
end
