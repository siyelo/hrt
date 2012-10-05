require File.dirname(__FILE__) + '/../spec_helper'

describe CodeSplit do
  describe "Validations" do
    subject { basic_setup_activity; FactoryGirl.create(:code_split, :activity => @activity) }
    it { should validate_presence_of(:activity_id) }
    it { should validate_presence_of(:code_id) }
    it { should ensure_inclusion_of(:percentage).in_range(0..100).with_message("must be between 0 and 100") }

    it "does not validate percentage when it is not present" do
      subject.percentage = nil
      subject.valid?.should be_true
    end

    it "should not allow same code to be assigned twice to an activity" do
      basic_setup_activity
      purpose = FactoryGirl.create(:purpose, :name => 'purpose1')
      PurposeBudgetSplit.update_classifications(@activity, { purpose.id => 5, purpose.id => 6  })
      purpose.code_splits.first.percentage.should == 6
    end
  end

  describe "Associations" do
    it { should belong_to :activity }
    it { should belong_to :code }
  end

  describe "Attributes" do
    it { should allow_mass_assignment_of(:activity) }
    it { should allow_mass_assignment_of(:code) }
    it { should allow_mass_assignment_of(:percentage) }
    it { should allow_value("100").for(:percentage) }
    it { should allow_value("1").for(:percentage) }
    it { should allow_value("0").for(:percentage) }
    it { should_not allow_value("101").for(:percentage) }
  end

  describe "named scopes" do
    it "with_activity" do
      basic_setup_project
      activity1 = FactoryGirl.create(:activity, :data_response => @response, :project => @project)
      split1    = FactoryGirl.create(:implementer_split, :activity => activity1,
                         :budget => 100, :spend => 200, :organization => @organization)
      activity2 = FactoryGirl.create(:activity, :data_response => @response, :project => @project)
      split2    = FactoryGirl.create(:implementer_split, :activity => activity2,
                         :budget => 100, :spend => 200, :organization => @organization)

      purpose   = FactoryGirl.create(:purpose, :name => 'purpose1')

      ca1       = FactoryGirl.create(:purpose_budget_split, :activity => activity1, :code => purpose)
      ca2       = FactoryGirl.create(:purpose_budget_split, :activity => activity2, :code => purpose)

      CodeSplit.with_activity(activity1.id).should == [ca1]
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

    it "with_type" do
      basic_setup_project
      activity = FactoryGirl.create(:activity, :data_response => @response, :project => @project)
      split    = FactoryGirl.create(:implementer_split, :activity => activity,
                         :budget => 100, :spend => 200, :organization => @organization)
      purpose  = FactoryGirl.create(:purpose, :name => 'purpose1')

      ca1      = FactoryGirl.create(:purpose_budget_split, :activity => activity, :code => purpose)
      ca2      = FactoryGirl.create(:purpose_spend_split,  :activity => activity, :code => purpose)

      CodeSplit.with_type('PurposeBudgetSplit').should == [ca1]
      CodeSplit.with_type('PurposeSpendSplit').should == [ca2]
    end

    it "automatically calculates the cached amount from the given % (and corresponding sub-activity rollup amount)" do
      basic_setup_project
      activity = FactoryGirl.create(:activity, :data_response => @response, :project => @project)
      split    = FactoryGirl.create(:implementer_split, :activity => activity,
                         :budget => 100, :spend => 200, :organization => @organization)
      purpose  = FactoryGirl.create(:purpose, :name => 'purpose1')
      activity.reload
      activity.save # get new cached implementer split total
      # at time of writing you must call one of the 'bulk' update APIs for classifications to have their cached amounts
      # and sum of children recalculated
      # i.e. you can't create individuals (below) since there are not yet any callbacks to keep each coding's cached_amount up to date
      #  ca1      = FactoryGirl.create(:purpose_budget_split, :activity => activity, :code => code, :percentage => '100', :cached_amount => nil)
      #  ca2      = FactoryGirl.create(:purpose_spend_split,  :activity => activity, :code => code, :percentage => '100', :cached_amount => nil)
      PurposeBudgetSplit.update_classifications(activity, { purpose.id => 100 })   # 100 means 100%
      PurposeSpendSplit.update_classifications(activity, { purpose.id => 100 })
      activity.reload
      cb1 = activity.purpose_budget_splits.first
      cb1.cached_amount.to_f.should == 100
      cs1 = activity.purpose_spend_splits.first
      cs1.cached_amount.to_f.should == 200
      CodeSplit.all.should == [cb1, cs1]
      CodeSplit.sorted.should == [cs1, cb1]
    end
 end

  describe "updating amounts" do
    before :each do
      basic_setup_project
      activity = FactoryGirl.create(:activity, :data_response => @response, :project => @project)
      split    = FactoryGirl.create(:implementer_split, :activity => activity,
                         :budget => 100, :spend => 200, :organization => @organization)
      @assignment = FactoryGirl.create(:code_split, :activity => activity)
    end
  end

  describe "#self.update_classifications" do
    before :each do
      @request      = FactoryGirl.create :data_request
      @organization = FactoryGirl.create :organization
      user = FactoryGirl.create :user, :organization => @organization
      @response     = @organization.latest_response
      @project      = FactoryGirl.create(:project, :data_response => @response)
      @activity     = FactoryGirl.create(:activity, :data_response => @response, :project => @project)
    end

    context "when classifications does not exist" do
      context "when submitting empty classifications" do
        it "does not saves anything" do
          classifications = {}
          coding_type     = 'PurposeBudgetSplit'
          PurposeBudgetSplit.update_classifications(@activity, classifications)
          PurposeBudgetSplit.count.should == 0
        end
      end

      context "when submitting non empty classifications" do
        before :each do
          @purpose1 = FactoryGirl.create(:purpose)
          @purpose2 = FactoryGirl.create(:purpose)
        end

        context "when submitting percentages <= 100" do
          it "creates code assignments" do
            classifications = { @purpose1.id => 100, @purpose2.id => 20 }
            PurposeBudgetSplit.update_classifications(@activity, classifications)
            PurposeBudgetSplit.count.should == 2
            assignments = PurposeBudgetSplit.all
            assignments.detect{|ca| ca.code_id == @purpose1.id}.percentage.should == 100
            assignments.detect{|ca| ca.code_id == @purpose2.id}.percentage.should == 20
          end
        end

        context "when submitting percentages > 100" do
          it "creates code assignments" do
            classifications = { @purpose1.id => 100, @purpose2.id => 101 }
            PurposeBudgetSplit.update_classifications(@activity, classifications)

            PurposeBudgetSplit.count.should == 1
            assignments = PurposeBudgetSplit.all
            assignments.detect{|ca| ca.code_id == @purpose1.id}.percentage.should == 100
          end
        end
      end
    end

    context "when classifications exist" do
      context "when submitting classifications" do
        before :each do
          @purpose1 = FactoryGirl.create(:purpose)
          @purpose2 = FactoryGirl.create(:purpose)
        end

        context "when submitting percentages" do
          it "creates code assignments" do
            FactoryGirl.create(:purpose_budget_split, :activity => @activity,
                    :code => @purpose1, :percentage => 10)
            FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @purpose2)
            PurposeBudgetSplit.count.should == 2

            # when submitting existing classifications, it updates them
            classifications = { @purpose1.id => 11, @purpose2.id => 22 }
            PurposeBudgetSplit.update_classifications(@activity, classifications)

            PurposeBudgetSplit.count.should == 2
            assignments = CodeSplit.all
            assignments.detect{|ca| ca.code_id == @purpose1.id}.percentage.should == 11
            assignments.detect{|ca| ca.code_id == @purpose2.id}.percentage.should == 22
          end

          it "rounds percentages off to two decimal places" do
            @cb = FactoryGirl.create(:purpose_budget_split, :activity => @activity, :code => @purpose1, :percentage => 57.344656)
            @cb.percentage.to_f.should == 57.34
          end

          it "rounds percentages off to two decimal places" do
            @cb = FactoryGirl.create(:purpose_spend_split, :activity => @activity, :code => @purpose1, :percentage => 52.7388)
            @cb.percentage.to_f.should == 52.74
          end
        end
      end
    end
  end
end
