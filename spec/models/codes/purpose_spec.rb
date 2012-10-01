require 'spec_helper'

describe Purpose do
  it "can return last version codes" do
    FactoryGirl.create(:location, version: 3) # test code filtering

    code1 = FactoryGirl.create(:purpose, version: 1)
    Purpose.with_last_version.should == [code1]

    code2 = FactoryGirl.create(:purpose, version: 2)
    Purpose.with_last_version.should == [code2]
  end
end
