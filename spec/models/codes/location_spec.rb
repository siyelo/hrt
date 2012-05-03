require File.dirname(__FILE__) + '/../../spec_helper'

describe Location do
  it "should have alias for short_display called name" do
    loc = Factory.build :location, :short_display => 'some loc'
    loc.name.should == 'some loc'
  end
end
