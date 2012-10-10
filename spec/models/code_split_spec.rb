require File.dirname(__FILE__) + '/../spec_helper'

describe CodeSplit do
  describe "Attributes" do
    it { should allow_mass_assignment_of(:activity) }
    it { should allow_mass_assignment_of(:code) }
    it { should allow_mass_assignment_of(:percentage) }
    it { should allow_value("100").for(:percentage) }
    it { should allow_value("1").for(:percentage) }
    it { should allow_value("0").for(:percentage) }
    it { should_not allow_value("101").for(:percentage) }
  end

  describe "Validations" do
    subject { basic_setup_activity; FactoryGirl.create(:code_split, :activity => @activity) }

    it { should validate_presence_of(:activity_id) }
    it { should validate_presence_of(:code_id) }
    it { should ensure_inclusion_of(:percentage).in_range(0..100).with_message("must be between 0 and 100") }

    it "does not validate percentage when it is not present" do
      subject.percentage = nil
      subject.valid?.should be_true
    end
  end

  describe "Associations" do
    it { should belong_to :activity }
    it { should belong_to :code }
  end

  describe "named scopes" do
    it "with_activity" do
      basic_setup_project
      activity1 = FactoryGirl.create(:activity,
                   :data_response => @response, :project => @project)
      FactoryGirl.create(:implementer_split, :activity => activity1,
                  :budget => 100, :spend => 200, :organization => @organization)
      activity2 = FactoryGirl.create(:activity, :data_response => @response,
                                     :project => @project)
      FactoryGirl.create(:implementer_split, :activity => activity2,
                  :budget => 100, :spend => 200, :organization => @organization)

      purpose = FactoryGirl.create(:purpose, :name => 'purpose1')

      split1 = FactoryGirl.create(:purpose_budget_split,
                                  :activity => activity1, :code => purpose)
      split2 = FactoryGirl.create(:purpose_budget_split,
                                  :activity => activity2, :code => purpose)

      CodeSplit.with_activity(activity1.id).should == [split1]
      CodeSplit.with_activity(activity2.id).should == [split2]
    end

    it "with_activities" do
      basic_setup_project
      activity1 = FactoryGirl.create(:activity, :data_response => @response, :project => @project)
      split1    = FactoryGirl.create(:implementer_split, :activity => activity1,
                         :budget => 100, :spend => 200, :organization => @organization)
      activity2 = FactoryGirl.create(:activity, :data_response => @response, :project => @project)
      split2    = FactoryGirl.create(:implementer_split, :activity => activity2,
                         :budget => 100, :spend => 200, :organization => @organization)
      activity3 = FactoryGirl.create(:activity, :data_response => @response, :project => @project)
      split3    = FactoryGirl.create(:implementer_split, :activity => activity3,
                         :budget => 100, :spend => 200, :organization => @organization)
      purpose   = FactoryGirl.create(:purpose, :name => 'purpose1')

      ca1       = FactoryGirl.create(:purpose_budget_split, :activity => activity1, :code => purpose)
      ca2       = FactoryGirl.create(:purpose_budget_split, :activity => activity2, :code => purpose)
      ca3       = FactoryGirl.create(:purpose_budget_split, :activity => activity3, :code => purpose)

      CodeSplit.with_activities([activity1.id, activity3.id]).should == [ca1, ca3]
    end

    describe ".purposes" do
      it "can filter code splits by purposes" do
        basic_setup_activity
        split = FactoryGirl.create(:purpose_budget_split, activity: @activity)

        CodeSplit.purposes.should == [split]
        CodeSplit.inputs.should be_empty
        CodeSplit.locations.should be_empty
      end
    end

    describe ".inputs" do
      it "can filter code splits by inputs" do
        basic_setup_activity
        split = FactoryGirl.create(:input_budget_split, activity: @activity)

        CodeSplit.inputs.should == [split]
        CodeSplit.purposes.should be_empty
        CodeSplit.locations.should be_empty
      end
    end

    describe ".locations" do
      it "can filter code splits by location" do
        basic_setup_activity
        split = FactoryGirl.create(:location_budget_split, activity: @activity)

        CodeSplit.locations.should == [split]
        CodeSplit.purposes.should be_empty
        CodeSplit.inputs.should be_empty
      end
    end

    describe ".budget" do
      it "can filter code splits by budget" do
        basic_setup_activity
        split = FactoryGirl.create(:purpose_budget_split, activity: @activity)

        CodeSplit.budget.should == [split]
        CodeSplit.spend.should be_empty
      end
    end

    describe ".spend" do
      it "can filter code splits by spend" do
        basic_setup_activity
        split = FactoryGirl.create(:purpose_spend_split, activity: @activity)

        CodeSplit.spend.should == [split]
        CodeSplit.budget.should be_empty
      end
    end

    describe ".leaf" do
      it "can return leaf code splits" do
        basic_setup_activity
        split1 = FactoryGirl.create(:purpose_spend_split, activity: @activity,
                                    sum_of_children: 10)
        split2 = FactoryGirl.create(:purpose_spend_split, activity: @activity,
                                    sum_of_children: 0)

        CodeSplit.leaf.should == [split2]
      end

    end
  end
end
