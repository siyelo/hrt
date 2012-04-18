require File.dirname(__FILE__) + '/../../spec_helper'

describe Activity, "Currency" do
  describe "currency" do
    it "complains when you dont have a project (therefore currency)" do
      lambda { activity = Factory(:activity, :projects => []) }.should raise_error
    end

    it "returns project currency when activity has currency" do
      basic_setup_response
      @project = Factory(:project, :data_response => @response, :currency => 'USD')
      activity = Factory(:activity, :data_response => @response, :project => @project)
      activity.currency.should == "USD"
    end
  end

  describe "currency convenience lookups on DR/Project" do
    before :each do
      @organization = Factory(:organization, :currency => 'RWF')
      @data_request = Factory(:data_request, :organization => @organization)
      @dr           = @organization.latest_response
      @project      = Factory(:project, :data_response => @dr)
      @a            = Factory(:activity, :data_response => @dr, :project => @project)
    end

    it "should return the organization's currency, unless the project overrides it" do
      @a.currency.should == "RWF"

      p = @a.project
      p.currency = 'CHF'
      p.save

      @a.reload
      @a.currency.should == "CHF"
    end
  end
end
