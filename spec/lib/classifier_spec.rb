require 'spec_helper'

describe Classifier do
  describe "#self.update_classifications" do
    before :each do
      @request      = FactoryGirl.create :data_request
      @organization = FactoryGirl.create :organization
      user = FactoryGirl.create :user, organization: @organization
      @response     = @organization.latest_response
      @project      = FactoryGirl.create(:project, data_response: @response)
      @activity     = FactoryGirl.create(:activity, data_response: @response, project: @project)
    end

    context "when classifications does not exist" do
      let(:purpose1) { FactoryGirl.create(:purpose) }
      let(:purpose2) { FactoryGirl.create(:purpose) }

      it "classifies a code only once" do
        basic_setup_activity

        classifier = Classifier.new(@activity, :purpose, :spend)
        classifier.update_classifications({ purpose1.id => 5, purpose1.id => 6 })

        splits = purpose1.code_splits.purposes.spend.all
        splits.length.should == 1
        splits.first.percentage.should == 6
      end

      it "creates code splits" do
        classifications = { purpose1.id => 100, purpose2.id => 20 }
        classifier = Classifier.new(@activity, :purpose, :budget)
        classifier.update_classifications(classifications)
        splits = CodeSplit.purposes.budget.all
        splits.length.should == 2
        splits.detect{|ca| ca.code_id == purpose1.id}.percentage.should == 100
        splits.detect{|ca| ca.code_id == purpose2.id}.percentage.should == 20
      end

      it "does not create anything" do
        classifications = {}
        classifier = Classifier.new(@activity, :purpose, :budget)
        classifier.update_classifications({})
        CodeSplit.count.should == 0
      end

      it "rejects invalid percentage amounts" do
        classifications = { purpose1.id => 100, purpose2.id => 101 }
        classifier = Classifier.new(@activity, :purpose, :budget)
        classifier.update_classifications(classifications)

        splits = CodeSplit.purposes.budget.all
        splits.length.should == 1
        splits.detect{|ca| ca.code_id == purpose1.id}.percentage.should == 100
      end
    end

    context "when classifications exist" do
      let(:purpose1) { FactoryGirl.create(:purpose) }
      let(:purpose2) { FactoryGirl.create(:purpose) }

      it "updates existing classifications" do
        FactoryGirl.create(:purpose_budget_split, activity: @activity,
                           code: purpose1, percentage: 10)
        FactoryGirl.create(:purpose_budget_split, activity: @activity,
                           code: purpose2)
        CodeSplit.purposes.budget.count.should == 2

        # when submitting existing classifications, it updates them
        classifications = { purpose1.id => 11, purpose2.id => 22 }
        classifier = Classifier.new(@activity, :purpose, :budget)
        classifier.update_classifications(classifications)

        splits = CodeSplit.purposes.budget
        splits.length.should == 2
        splits.detect{|ca| ca.code_id == purpose1.id}.percentage.should == 11
        splits.detect{|ca| ca.code_id == purpose2.id}.percentage.should == 22
      end

      it "deletes old code splits" do
        FactoryGirl.create(:purpose_budget_split, activity: @activity,
                           code: purpose1, percentage: 10)

        classifier = Classifier.new(@activity, :purpose, :budget)
        classifier.update_classifications({purpose1.id => 10})
        splits = CodeSplit.purposes.budget.all
        splits.length.should == 1
        splits.first.percentage.should == 10

        FactoryGirl.create(:purpose_budget_split, activity: @activity,
                           code: purpose2, percentage: 20)

        classifier = Classifier.new(@activity, :purpose, :budget)
        classifier.update_classifications({purpose2.id => 20})

        splits = CodeSplit.purposes.budget.all
        splits.length.should == 1
        splits.first.percentage.should == 20
      end

      it "rounds percentages off to two decimal places" do
        split = FactoryGirl.create(:purpose_budget_split,
          activity: @activity, code: purpose1, percentage: 57.344656)
        split.percentage.to_f.should == 57.34
      end

      it "rounds percentages off to two decimal places" do
        split = FactoryGirl.create(:purpose_spend_split,
          activity: @activity, code: purpose1, percentage: 52.7388)
        split.percentage.to_f.should == 52.74
      end
    end

    it "automatically calculates the cached amount" do
      basic_setup_project
      activity = FactoryGirl.create(:activity, data_response: @response, project: @project)
      implementer_split = FactoryGirl.create(:implementer_split, activity: activity,
                         budget: 100, spend: 200, organization: @organization)
      purpose  = FactoryGirl.create(:purpose, name: 'purpose1')
      activity.reload
      activity.save # get new cached implementer split total

      classifier = Classifier.new(activity, :purpose, :budget)
      classifier.update_classifications({purpose.id => 100})

      activity.reload

      split1 = activity.code_splits.purposes.budget.first
      split1.cached_amount.to_f.should == 100
    end
  end
end
