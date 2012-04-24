require 'spec_helper'

describe Admin::ResponsesController do
  before :each do
    login_as_admin
  end

  describe "index" do
    before :each do
      @request1 = Factory(:data_request)
      @admin.set_current_response_to_latest!
      @organization = Factory(:organization)
      @data_response = @organization.responses.find_by_data_request_id(@request1.id)
      @all_organizations = [@admin.organization, @request1.organization, @organization]
    end

    it "should return all organizations when not using any filter" do
      get :index
      assigns(:organizations).should == @all_organizations
    end

    it "should return all organizations when using All filter" do
      get :index, :filter => 'All'
      assigns(:organizations).should == @all_organizations
    end

    it "should ignore unrecognized filters" do
      get :index, :filter => 'Blah'
      assigns(:organizations).should == @all_organizations
    end

    it "should filter by empty response" do
      Factory(:organization, :raw_type => 'Dispensary') #non-reporting
      get :index, :filter => 'Not Started'
      assigns(:organizations).size.should == 3
    end

    it "should filter by started response" do
      @data_response.state = 'started'
      @data_response.save!
      get :index, :filter => 'Started'
      assigns(:organizations).should == [@organization]
    end

    it "should filter by rejected response" do
      @data_response.state = 'rejected'
      @data_response.save!
      get :index, :filter => 'Rejected'
      assigns(:organizations).should == [@organization]
    end

    it "should filter by submitted response" do
      @data_response.state = 'submitted'
      @data_response.save!
      get :index, :filter => 'Submitted'
      assigns(:organizations).should == [@organization]
    end

    it "should filter by complete response" do
      @data_response.state = 'accepted'
      @data_response.save!
      get :index, :filter => 'Accepted'
      assigns(:organizations).should == [@organization]
    end

    it "should display all organizations" do
      organization1 = Factory.build(:organization, :raw_type => '')
      organization1.save(false)

      get :index, :filter => 'All'
      assigns(:organizations).size.should == @all_organizations.size + 1
    end
  end
end
