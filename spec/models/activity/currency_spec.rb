require File.dirname(__FILE__) + '/../../spec_helper'

describe Activity, "Currency" do
  describe "currency" do
    it "complains when you dont have a project (therefore currency)" do
      lambda { activity = FactoryGirl.create(:activity, :projects => []) }.should raise_error
    end

    it "returns project currency when activity has currency" do
      basic_setup_response
      @project = FactoryGirl.create(:project, :data_response => @response, :currency => 'USD')
      activity = FactoryGirl.create(:activity, :data_response => @response, :project => @project)
      activity.currency.should == "USD"
    end
  end
end
