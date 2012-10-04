require 'spec_helper'

describe Beneficiary do
  describe "Attributes" do
    it { should allow_mass_assignment_of(:name) }
  end

  describe "Validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:version) }
    it { should_not allow_mass_assignment_of(:version) }
  end

  describe "Associations" do
    it { should have_and_belong_to_many(:activities) }
  end

  describe "#with_last_version" do
    it "can return last version codes" do
      code1 = FactoryGirl.create(:beneficiary, version: 1)
      Beneficiary.with_last_version.should == [code1]

      code2 = FactoryGirl.create(:beneficiary, version: 2)
      Beneficiary.with_last_version.should == [code2]
    end
  end
end
