require File.dirname(__FILE__) + '/../../spec_helper'

# All logic specific to InputSplit type assignments
describe InputSplit do
  describe "named scopes" do
    before :each do
      basic_setup_project
      activity = FactoryGirl.create(:activity, :data_response => @response, :project => @project)

      code1    = FactoryGirl.create(:input, :name => 'code1')
      code2    = FactoryGirl.create(:input, :name => 'code2')
      code11   = FactoryGirl.create(:input, :name => 'code11', :parent => code1)
      code21   = FactoryGirl.create(:input, :name => 'code21', :parent => code2)

      @cs1      = FactoryGirl.create(:input_spend_split, :activity => activity, :code => code1)
      @cs2      = FactoryGirl.create(:input_spend_split, :activity => activity, :code => code2)
      @cs11     = FactoryGirl.create(:input_spend_split, :activity => activity, :code => code11)
      @cs21     = FactoryGirl.create(:input_spend_split, :activity => activity, :code => code21)

      @ca1      = FactoryGirl.create(:input_budget_split, :activity => activity, :code => code1)
      @ca2      = FactoryGirl.create(:input_budget_split, :activity => activity, :code => code2)
      @ca11     = FactoryGirl.create(:input_budget_split, :activity => activity, :code => code11)
      @ca21     = FactoryGirl.create(:input_budget_split, :activity => activity, :code => code21)
    end

    it "#roots" do
      InputSpendSplit.roots.should == [@cs1, @cs2]
      InputBudgetSplit.roots.should == [@ca1, @ca2]
    end
  end
end
