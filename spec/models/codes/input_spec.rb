require 'spec_helper'

describe Input do

  it "can return last version codes" do
    FactoryGirl.create(:location, version: 3) # test code filtering

    code1 = FactoryGirl.create(:input, version: 1)
    Input.last_version.should == [code1]

    code2 = FactoryGirl.create(:input, version: 2)
    Input.last_version.should == [code2]
  end
end
