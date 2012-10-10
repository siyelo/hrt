require File.dirname(__FILE__) + '/../../spec_helper'


describe Activity, "Classification" do
  before :each do
    basic_setup_project
  end

   [
     ['purpose_budget_splits_valid?', :purpose, :budget, 'purposes_classified?'],
     ['purpose_spend_splits_valid?', :purpose, :spend, 'purposes_classified?'],
     ['location_budget_splits_valid?', :location, :budget, 'locations_classified?'],
     ['location_spend_splits_valid?', :location, :spend, 'locations_classified?'],
     ['input_budget_splits_valid?', :input, :budget, 'inputs_classified?'],
     ['input_spend_splits_valid?', :input, :spend, 'inputs_classified?']
   ].each do |valid_method, code_type_key, amount_type, all_valid_method|
    describe "#{valid_method}" do
      before :each do
        @activity = FactoryGirl.create(:activity, :data_response => @response,
                           :project => @project)
        @split = FactoryGirl.create :implementer_split, :activity => @activity,
          amount_type => 100, :organization => @organization
        @code     = FactoryGirl.create code_type_key
        @activity.reload
        @activity.save
      end

      it "is classified when #{amount_type} equals 100 percent" do
        @activity.send(valid_method).should be_false #sanity
        classifications = {@code.id.to_s => 100}
        classifier = Classifier.new(@activity, code_type_key, amount_type)
        classifier.update_classifications(classifications)
        @activity.reload
        @activity.send(valid_method).should be_true
        @activity.send(all_valid_method).should be_true
      end

      it "is not classified when #{amount_type} does not equal 100%" do
        @activity.send(valid_method).should be_false #sanity
        classifications = {@code.id.to_s => 99}
        classifier = Classifier.new(@activity, code_type_key, amount_type)
        classifier.update_classifications(classifications)
        @activity.reload
        @activity.send(valid_method).should be_false
        @activity.send(all_valid_method).should be_false
      end
    end
  end

  describe "budget_classified?" do
    before :each do
      basic_setup_activity
      @split = FactoryGirl.create :implementer_split, :activity => @activity,
        :spend => 100, :budget => 100, :organization => @organization
      @activity.reload
      @activity.save
    end

    it "is budget_classified? when all budgets are classified" do
      @activity.stub(:purpose_budget_splits_valid?) { true }
      @activity.stub(:location_budget_splits_valid?) { true }
      @activity.stub(:input_budget_splits_valid?) { true }
      @activity.budget_classified?.should be_true
    end

    it "is not budget_classified? when budget is not classified" do
      @activity.stub(:purpose_budget_splits_valid?) { false }
      @activity.stub(:location_budget_splits_valid?) { true }
      @activity.stub(:input_budget_splits_valid?) { true }
      @activity.budget_classified?.should be_false
    end

    it "is not budget_classified? when districts are not classified" do
      @activity.stub(:purpose_budget_splits_valid?) { true }
      @activity.stub(:location_budget_splits_valid?) { false }
      @activity.stub(:input_budget_splits_valid?) { true }
      @activity.budget_classified?.should be_false
    end

    it "is not budget_classified? when cost categories are not classified" do
      @activity.stub(:purpose_budget_splits_valid?) { true }
      @activity.stub(:location_budget_splits_valid?) { true }
      @activity.stub(:input_budget_splits_valid?) { false }
      @activity.budget_classified?.should be_false
    end

    it "is budget_classified? when no budgets are classified & budget is blank or zero" do
      @split.budget = nil; @split.save
      @activity.reload; @activity.save
      @activity.stub(:purpose_budget_splits_valid?) { false }
      @activity.stub(:location_budget_splits_valid?) { false }
      @activity.stub(:input_budget_splits_valid?) { false }
      @activity.budget_classified?.should be_true
    end
  end

  describe "spend_classified?" do
    before :each do
      basic_setup_activity
      @split = FactoryGirl.create :implementer_split, :activity => @activity,
        :spend => 100, :budget => 100, :organization => @organization
      @activity.reload
      @activity.save
    end
    it "is spend_classified? when all spends are classified" do
      @activity.stub(:purpose_spend_splits_valid?) { true }
      @activity.stub(:location_spend_splits_valid?) { true }
      @activity.stub(:input_spend_splits_valid?) { true }
      @activity.spend_classified?.should be_true
    end

    it "is not spend_classified? when spend is not classified" do
      @activity.stub(:purpose_spend_splits_valid?) { false }
      @activity.stub(:location_spend_splits_valid?) { true }
      @activity.stub(:input_spend_splits_valid?) { true }
      @activity.spend_classified?.should be_false
    end

    it "is not spend_classified? when districts are not classified" do
      @activity.stub(:purpose_spend_splits_valid?) { true }
      @activity.stub(:location_spend_splits_valid?) { false }
      @activity.stub(:input_spend_splits_valid?) { true }
      @activity.spend_classified?.should be_false
    end

    it "is not spend_classified? when cost categories are not classified" do
      @activity.stub(:purpose_spend_splits_valid?) { true }
      @activity.stub(:location_spend_splits_valid?) { true }
      @activity.stub(:input_spend_splits_valid?) { false }
      @activity.spend_classified?.should be_false
    end

    it "is spend_classified? when no spends are classified & spend is blank or zero" do
      @split.spend = nil; @split.save
      @activity.reload; @activity.save
      @activity.stub(:purpose_spend_splits_valid?) { false }
      @activity.stub(:location_spend_splits_valid?) { false }
      @activity.stub(:input_spend_splits_valid?) { false }
      @activity.spend_classified?.should be_true
    end
  end

  describe "classified?" do
    before :each do
      basic_setup_activity
      @split = FactoryGirl.create :implementer_split, :activity => @activity,
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
