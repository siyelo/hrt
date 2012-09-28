require 'spec_helper'

describe "Purpose" do
  it "can return last version codes" do
    FactoryGirl.create(:input, version: 3) # test code filtering

    code1 = FactoryGirl.create(:mtef_code, version: 1)
    Code.purposes.with_last_version.should == [code1]

    code2 = FactoryGirl.create(:mtef_code, version: 2)
    Code.purposes.with_last_version.should == [code2]
  end
end
