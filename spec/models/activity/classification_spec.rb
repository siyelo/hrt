require File.dirname(__FILE__) + '/../../spec_helper'


describe Activity, "Classification" do
  before :each do
    basic_setup_project
  end


  [['coding_budget_valid?', CodingBudget, :budget, :mtef_code, 'purposes_classified?'],
   ['coding_spend_valid?', CodingSpend, :spend, :mtef_code, 'purposes_classified?'],
   ['coding_budget_district_valid?', CodingBudgetDistrict, :budget, :location, 'locations_classified?'],
   ['coding_spend_district_valid?', CodingSpendDistrict, :spend,  :location, 'locations_classified?'],
   ['coding_budget_cc_valid?', CodingBudgetCostCategorization, :budget, :cost_category_code, 'inputs_classified?'],
   ['coding_spend_cc_valid?', CodingSpendCostCategorization, :spend,  :cost_category_code, 'inputs_classified?']
   ].each do |valid_method, klass, amount_field, code_type, all_valid_method|
    describe "#{valid_method}" do
      before :each do
        @activity = Factory(:activity, :data_response => @response,
                           :project => @project)
        @split = Factory :implementer_split, :activity => @activity,
          amount_field => 100, :organization => @organization
        @code     = Factory code_type
        @activity.reload
        @activity.save
      end

      it "is classified when #{amount_field} equals 100 percent" do
        @activity.send(valid_method).should be_false #sanity
        params = {@code.id.to_s => 100}
        klass.update_classifications(@activity, params)
        @activity.reload
        @activity.send(valid_method).should be_true
        @activity.send(all_valid_method).should be_true
      end

      it "is not classified when #{amount_field} does not equal 100%" do
        @activity.send(valid_method).should be_false #sanity
        params = {@code.id.to_s => 99}
        klass.update_classifications(@activity, params)
        @activity.reload
        @activity.send(valid_method).should be_false
        @activity.send(all_valid_method).should be_false
      end
    end
  end

  describe "budget_classified?" do
    before :each do
      basic_setup_activity
      @split = Factory :implementer_split, :activity => @activity,
        :spend => 100, :budget => 100, :organization => @organization
      @activity.reload
      @activity.save
    end

    it "is budget_classified? when all budgets are classified" do
      @activity.stub(:coding_budget_valid?) { true }
      @activity.stub(:coding_budget_district_valid?) { true }
      @activity.stub(:coding_budget_cc_valid?) { true }
      @activity.budget_classified?.should be_true
    end

    it "is not budget_classified? when budget is not classified" do
      @activity.stub(:coding_budget_valid?) { false }
      @activity.stub(:coding_budget_district_valid?) { true }
      @activity.stub(:coding_budget_cc_valid?) { true }
      @activity.budget_classified?.should be_false
    end

    it "is not budget_classified? when districts are not classified" do
      @activity.stub(:coding_budget_valid?) { true }
      @activity.stub(:coding_budget_district_valid?) { false }
      @activity.stub(:coding_budget_cc_valid?) { true }
      @activity.budget_classified?.should be_false
    end

    it "is not budget_classified? when cost categories are not classified" do
      @activity.stub(:coding_budget_valid?) { true }
      @activity.stub(:coding_budget_district_valid?) { true }
      @activity.stub(:coding_budget_cc_valid?) { false }
      @activity.budget_classified?.should be_false
    end

    it "is budget_classified? when no budgets are classified & budget is blank or zero" do
      @split.budget = nil; @split.save
      @activity.reload; @activity.save
      @activity.stub(:coding_budget_valid?) { false }
      @activity.stub(:coding_budget_district_valid?) { false }
      @activity.stub(:coding_budget_cc_valid?) { false }
      @activity.budget_classified?.should be_true
    end
  end

  describe "spend_classified?" do
    before :each do
      basic_setup_activity
      @split = Factory :implementer_split, :activity => @activity,
        :spend => 100, :budget => 100, :organization => @organization
      @activity.reload
      @activity.save
    end
    it "is spend_classified? when all spends are classified" do
      @activity.stub(:coding_spend_valid?) { true }
      @activity.stub(:coding_spend_district_valid?) { true }
      @activity.stub(:coding_spend_cc_valid?) { true }
      @activity.spend_classified?.should be_true
    end

    it "is not spend_classified? when spend is not classified" do
      @activity.stub(:coding_spend_valid?) { false }
      @activity.stub(:coding_spend_district_valid?) { true }
      @activity.stub(:coding_spend_cc_valid?) { true }
      @activity.spend_classified?.should be_false
    end

    it "is not spend_classified? when districts are not classified" do
      @activity.stub(:coding_spend_valid?) { true }
      @activity.stub(:coding_spend_district_valid?) { false }
      @activity.stub(:coding_spend_cc_valid?) { true }
      @activity.spend_classified?.should be_false
    end

    it "is not spend_classified? when cost categories are not classified" do
      @activity.stub(:coding_spend_valid?) { true }
      @activity.stub(:coding_spend_district_valid?) { true }
      @activity.stub(:coding_spend_cc_valid?) { false }
      @activity.spend_classified?.should be_false
    end

    it "is spend_classified? when no spends are classified & spend is blank or zero" do
      @split.spend = nil; @split.save
      @activity.reload; @activity.save
      @activity.stub(:coding_spend_valid?) { false }
      @activity.stub(:coding_spend_district_valid?) { false }
      @activity.stub(:coding_spend_cc_valid?) { false }
      @activity.spend_classified?.should be_true
    end
  end

  describe "classified?" do
    before :each do
      basic_setup_activity
      @split = Factory :implementer_split, :activity => @activity,
        :spend => 100, :budget => 100, :organization => @organization
      @activity.reload
      @activity.save
    end

    it "is classified? when both budget and spend are classified" do
      @activity.stub(:budget_classified?) { true }
      @activity.stub(:spend_classified?) { true }
      @activity.classified?.should be_true
    end

    it "is true when only budget is classified" do
      @activity.stub(:budget_classified?) { false }
      @activity.stub(:spend_classified?) { true }
      @activity.classified?.should be_true
    end

    it "is true when only spend is classified" do
      @activity.stub(:budget_classified?) { true }
      @activity.stub(:spend_classified?) { false }
      @activity.classified?.should be_true
    end

    it "is not classified? when both are not classified" do
      @activity.stub(:budget_classified?) { false }
      @activity.stub(:spend_classified?) { false }
      @activity.classified?.should be_false
    end
  end
end
