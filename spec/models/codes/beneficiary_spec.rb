require 'spec_helper'

describe Beneficiary do
  it "can return last version codes" do
    FactoryGirl.create(:input, version: 3) # test code filtering

    code1 = FactoryGirl.create(:beneficiary, version: 1)
    Beneficiary.last_version.should == [code1]

    code2 = FactoryGirl.create(:beneficiary, version: 2)
    Beneficiary.last_version.should == [code2]
  end
end
