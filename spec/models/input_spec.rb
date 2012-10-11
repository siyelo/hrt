require 'spec_helper'

describe Input do

  describe "Attributes" do
    it { should allow_mass_assignment_of(:name) }
    it { should allow_mass_assignment_of(:description) }
    it { should_not allow_mass_assignment_of(:version) }
    it { should_not allow_mass_assignment_of(:parent_id) }
    it { should_not allow_mass_assignment_of(:lft) }
    it { should_not allow_mass_assignment_of(:rgt) }
  end

  describe "Validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:version) }
  end

  describe "Assocations" do
    it { should have_many(:code_splits).dependent(:destroy) }
  end

  describe "#with_last_version" do
    it "can return last version codes" do
      input1 = FactoryGirl.create(:input, version: 1)
      Input.with_last_version.should == [input1]

      input2 = FactoryGirl.create(:input, version: 2)
      Input.with_last_version.should == [input2]
    end
  end

  describe "Nested set (Tree)" do
    it "can return root inputs" do
      input1 = FactoryGirl.create(:input, name: "input1")
      input2 = FactoryGirl.create(:input, name: "input2")
      input2.move_to_child_of(input1)

      roots = Input.roots
      roots.should include(input1)
      roots.should_not include(input2)
    end
  end
end
