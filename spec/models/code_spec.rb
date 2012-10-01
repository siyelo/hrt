require File.dirname(__FILE__) + '/../spec_helper'

describe Code do
  describe "Attributes" do
    it { should allow_mass_assignment_of(:short_display) }
    it { should allow_mass_assignment_of(:long_display) }
    it { should allow_mass_assignment_of(:description) }
    it { should allow_mass_assignment_of(:type_string) }
    it { should allow_mass_assignment_of(:parent_id) }
    it { should allow_mass_assignment_of(:type) }
    it { should allow_mass_assignment_of(:hssp2_stratprog_val) }
    it { should allow_mass_assignment_of(:hssp2_stratobj_val) }
    it { should allow_mass_assignment_of(:sub_account) }
    it { should allow_mass_assignment_of(:nasa_code) }
    it { should allow_mass_assignment_of(:nha_code) }
    it { should allow_mass_assignment_of(:type_string) }
    it { should allow_mass_assignment_of(:parent_id) }
    it { should allow_mass_assignment_of(:official_name) }
    it { should allow_mass_assignment_of(:external_id) }
    it { should_not allow_mass_assignment_of(:version) }
  end

  describe "Associations" do
    it { should have_many(:code_splits).dependent(:destroy) }
    it { should have_many(:activities) }
  end

  describe "Validations" do
    it { should validate_presence_of(:short_display) }
  end

  describe "named scopes" do
    it "filter codes by type" do
      purpose  = FactoryGirl.create(:purpose)
      location = FactoryGirl.create(:location)

      Code.with_type('Purpose').should == [purpose]
      Code.with_type('Location').should == [location]
    end

    it "filter codes by types" do
      purpose  = FactoryGirl.create(:purpose)
      location = FactoryGirl.create(:location)

      Code.with_types(['Purpose', 'Location']).should == [purpose, location]
    end

    it "filter codes by activity root types" do
      purpose            = FactoryGirl.create(:purpose)
      cost_category_code = FactoryGirl.create(:cost_category_code)
      location           = FactoryGirl.create(:location)
      beneficiary        = FactoryGirl.create(:beneficiary)
      hssp_strat_prog    = FactoryGirl.create(:hssp_strat_prog)
      hssp_strat_obj     = FactoryGirl.create(:hssp_strat_obj)

      Code.purposes.should == [purpose]
    end
  end

  describe "deepest_nesting" do
    it "returns deepest nesting for 3 level" do
      # first level
      code1 = FactoryGirl.create(:code, :short_display => 'code1')

      # second level
      code11 = FactoryGirl.create(:code, :short_display => 'code11')
      code11.move_to_child_of(code1)

      # third level
      code111 = FactoryGirl.create(:code, :short_display => 'code111')
      code111.move_to_child_of(code11)

      Code.deepest_nesting.should == 3
    end
  end

  describe "roots with level" do
    it "returns roots with level" do
      # first level
      purpose1 = FactoryGirl.create(:purpose, :short_display => 'purpose1')

      # second level
      purpose11 = FactoryGirl.create(:purpose, :short_display => 'purpose11')
      purpose11.move_to_child_of(purpose1)

      Code.roots_with_level.should == [[0, purpose1.id], [1, purpose11.id]]
    end
  end

  describe "#name" do
    it "returns short_display as name" do
      code = FactoryGirl.create(:code, :short_display => 'Code name')
      code.name.should == 'Code name'
    end
  end

  describe "to_s" do
    it "returns short_display as to_s" do
      code = FactoryGirl.create(:code, :short_display => 'short_display')
      code.to_s.should == 'short_display'
    end
  end
end
