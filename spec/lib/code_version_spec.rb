require 'spec_helper'

describe CodeVersion do

  describe "#with_version" do
    it "can return last version codes" do
      purpose1 = FactoryGirl.create(:purpose, version: 1)
      Purpose.last_version.should == 1

      purpose2 = FactoryGirl.create(:purpose, version: 2)
      Purpose.last_version.should == 2
    end
  end

  describe "#with_last_version" do
    it "can return last version codes" do
      purpose1 = FactoryGirl.create(:purpose, version: 1)
      Purpose.with_last_version.should == [purpose1]

      purpose2 = FactoryGirl.create(:purpose, version: 2)
      Purpose.with_last_version.should == [purpose2]
    end
  end

  describe "#with_version" do
    it "can return last version codes" do
      purpose1 = FactoryGirl.create(:purpose, version: 1)
      purpose2 = FactoryGirl.create(:purpose, version: 2)

      Purpose.with_version(1).should == [purpose1]
      Purpose.with_version(2).should == [purpose2]
    end
  end

end
