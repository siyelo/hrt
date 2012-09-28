require File.dirname(__FILE__) + '/../../spec_helper'

describe Location do
  it "should have alias for short_display called name" do
    loc = FactoryGirl.build :location, :short_display => 'some loc'
    loc.name.should == 'some loc'
  end

  it "can return last version codes" do
    FactoryGirl.create(:input, version: 3) # test code filtering

    code1 = FactoryGirl.create(:location, version: 1)
    Location.last_version.should == [code1]

    code2 = FactoryGirl.create(:location, version: 2)
    Location.last_version.should == [code2]
  end
end
