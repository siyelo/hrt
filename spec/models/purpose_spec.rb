require 'spec_helper'

describe Purpose do

  describe "Attributes" do
    it { should allow_mass_assignment_of(:name) }
    it { should allow_mass_assignment_of(:description) }
    it { should allow_mass_assignment_of(:official_name) }
    it { should allow_mass_assignment_of(:sub_account) }
    it { should allow_mass_assignment_of(:hssp2_stratobj_val) }
    it { should allow_mass_assignment_of(:hssp2_stratprog_val) }
    it { should allow_mass_assignment_of(:mtef_code) }
    it { should allow_mass_assignment_of(:nasa_code) }
    it { should allow_mass_assignment_of(:nha_code) }
    it { should allow_mass_assignment_of(:nsp_code) }
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

  describe "Nested set (Tree)" do
    it "can return root inputs" do
      purpose1 = FactoryGirl.create(:purpose, name: "purpose1")
      purpose2 = FactoryGirl.create(:purpose, name: "purpose2")
      purpose2.move_to_child_of(purpose1)

      roots = Purpose.roots
      roots.should include(purpose1)
      roots.should_not include(purpose2)
    end
  end

  describe "#deepest_nesting" do
    it "returns deepest nesting for 3 level" do
      # first level
      purpose1 = FactoryGirl.create(:purpose, name: 'purpose1')

      # second level
      purpose11 = FactoryGirl.create(:purpose, name: 'purpose11')
      purpose11.move_to_child_of(purpose1)

      # third level
      purpose111 = FactoryGirl.create(:purpose, name: 'purpose111')
      purpose111.move_to_child_of(purpose11)

      Purpose.deepest_nesting.should == 3
    end
  end

  describe "#roots_with_level" do
    it "returns roots with level" do
      # first level
      purpose1 = FactoryGirl.create(:purpose, name: 'purpose1')

      # second level
      purpose11 = FactoryGirl.create(:purpose, name: 'purpose11')
      purpose11.move_to_child_of(purpose1)

      Purpose.roots_with_level.should == [[0, purpose1.id], [1, purpose11.id]]
    end
  end
end
