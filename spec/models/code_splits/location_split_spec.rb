require File.dirname(__FILE__) + '/../../spec_helper'

# All logic specific to InputSplit type assignments
describe LocationSplit do
  describe "named scopes" do
    before :each do
      basic_setup_project
      activity = FactoryGirl.create(:activity, :data_response => @response, :project => @project)

      code1    = FactoryGirl.create(:location, :short_display => 'code1')
      code2    = FactoryGirl.create(:location, :short_display => 'code2')
      code11   = FactoryGirl.create(:location, :short_display => 'code11', :parent => code1)
      code21   = FactoryGirl.create(:location, :short_display => 'code21', :parent => code2)

      @cs1      = FactoryGirl.create(:location_spend_split, :activity => activity, :code => code1)
      @cs2      = FactoryGirl.create(:location_spend_split, :activity => activity, :code => code2)
      @cs11     = FactoryGirl.create(:location_spend_split, :activity => activity, :code => code11)
      @cs21     = FactoryGirl.create(:location_spend_split, :activity => activity, :code => code21)

      @ca1      = FactoryGirl.create(:location_budget_split, :activity => activity, :code => code1)
      @ca2      = FactoryGirl.create(:location_budget_split, :activity => activity, :code => code2)
      @ca11     = FactoryGirl.create(:location_budget_split, :activity => activity, :code => code11)
      @ca21     = FactoryGirl.create(:location_budget_split, :activity => activity, :code => code21)
    end

    it "#roots" do
      LocationSpendSplit.roots.should == [@cs1, @cs2]
      LocationBudgetSplit.roots.should == [@ca1, @ca2]
    end
  end
end
