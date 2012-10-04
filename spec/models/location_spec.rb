require 'spec_helper'

describe Location do
  describe "Attributes" do
    it { should allow_mass_assignment_of(:name) }
  end

  describe "Validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:version) }
  end

  describe "Assocations" do
    it { should have_many(:code_splits).dependent(:destroy) }
  end

  describe "Scopes" do
    it "#national_level" do
      location1 = FactoryGirl.create(:location, name: 'National Level')
      location2 = FactoryGirl.create(:location, name: 'Bugesera')

      locations = Location.national_level
      locations.should include(location1)
      locations.should_not include(location2)
    end

    it "#without_national_level" do
      location1 = FactoryGirl.create(:location, name: 'National Level')
      location2 = FactoryGirl.create(:location, name: 'Bugesera')

      locations = Location.without_national_level
      locations.should_not include(location1)
      locations.should include(location2)
    end

    it "#sorted" do
      location1 = FactoryGirl.create(:location, name: 'B')
      location2 = FactoryGirl.create(:location, name: 'a')

      locations = Location.sorted
      locations.first.should == location2
      locations.last.should  == location1
    end
  end

  describe "#with_last_version" do
    it "can return last version codes" do
      location1 = FactoryGirl.create(:location, version: 1)
      Location.with_last_version.should == [location1]

      location2 = FactoryGirl.create(:location, version: 2)
      Location.with_last_version.should == [location2]
    end
  end
end
