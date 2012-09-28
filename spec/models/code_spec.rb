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
      mtef     = FactoryGirl.create(:mtef_code)
      location = FactoryGirl.create(:location)

      Code.with_type('Mtef').should == [mtef]
      Code.with_type('Location').should == [location]
    end

    it "filter codes by types" do
      mtef     = FactoryGirl.create(:mtef_code)
      location = FactoryGirl.create(:location)

      Code.with_types(['Mtef', 'Location']).should == [mtef, location]
    end

    it "filter codes by activity root types" do
      mtef               = FactoryGirl.create(:mtef_code)
      nha_code           = FactoryGirl.create(:nha_code)
      nasa_code          = FactoryGirl.create(:nasa_code)
      nsp_code           = FactoryGirl.create(:nsp_code)
      cost_category_code = FactoryGirl.create(:cost_category_code)
      location           = FactoryGirl.create(:location)
      beneficiary        = FactoryGirl.create(:beneficiary)
      hssp_strat_prog    = FactoryGirl.create(:hssp_strat_prog)
      hssp_strat_obj     = FactoryGirl.create(:hssp_strat_obj)

      Code.purposes.should == [mtef, nha_code, nasa_code, nsp_code]
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
      mtef = FactoryGirl.create(:mtef_code, :short_display => 'mtef')

      # second level
      nha = FactoryGirl.create(:nha_code, :short_display => 'nha')
      nha.move_to_child_of(mtef)

      # third level
      nsp = FactoryGirl.create(:nsp_code, :short_display => 'nsp')
      nsp.move_to_child_of(nha)

      # forth level
      nasa = FactoryGirl.create(:nasa_code, :short_display => 'nasa')
      nasa.move_to_child_of(nsp)

      Code.roots_with_level.should == [[0, mtef.id], [1, nha.id], [2, nsp.id], [3, nasa.id]]
      Mtef.roots_with_level.should == [[0, mtef.id], [1, nha.id], [2, nsp.id], [3, nasa.id]]
      Nha.roots_with_level.should == [[1, nha.id], [2, nsp.id], [3, nasa.id]]
      Nsp.roots_with_level.should == [[1, nsp.id], [2, nasa.id]]
      Nasa.roots_with_level.should == [[1, nasa.id]]
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
