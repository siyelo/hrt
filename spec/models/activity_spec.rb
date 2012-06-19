require File.dirname(__FILE__) + '/../spec_helper'

describe Activity do
  describe "Associations" do
    it { should belong_to(:data_response) }
    it { should belong_to(:project) }
    it { should belong_to(:previous) }
    it { should have_and_belong_to_many :beneficiaries }
    it { should have_many(:implementer_splits).dependent(:delete_all) }
    it { should have_many(:implementers) }
    it { should have_many(:purposes) }
    it { should have_many(:code_splits).dependent(:destroy) }
    it { should have_many(:comments).dependent(:destroy) }
    it { should have_many(:purpose_spend_splits).dependent(:destroy) }
    it { should have_many(:purpose_budget_splits).dependent(:destroy) }
    it { should have_many(:input_spend_splits).dependent(:destroy) }
    it { should have_many(:input_budget_splits).dependent(:destroy) }
    it { should have_many(:location_spend_splits).dependent(:destroy) }
    it { should have_many(:location_budget_splits).dependent(:destroy) }
    it { should have_many(:targets).dependent(:destroy) }
    it { should have_many(:outputs).dependent(:destroy) }
    it { should have_many(:leaf_budget_purposes) }
    it { should have_many(:leaf_spend_purposes) }
    it { should have_many(:leaf_budget_inputs) }
    it { should have_many(:leaf_spend_inputs) }
  end

  describe "Attributes" do
    it { should allow_mass_assignment_of(:name) }
    it { should allow_mass_assignment_of(:description) }
    it { should allow_mass_assignment_of(:project_id) }
    it { should allow_mass_assignment_of(:beneficiary_ids) }
    it { should allow_mass_assignment_of(:other_beneficiaries) }
    it { should allow_mass_assignment_of(:implementer_splits_attributes) }
    it { should allow_mass_assignment_of(:implementer_splits_attributes) }
    it { should allow_mass_assignment_of(:organization_ids) }
    it { should allow_mass_assignment_of(:targets_attributes) }
    it { should allow_mass_assignment_of(:outputs_attributes) }
    it { should allow_mass_assignment_of(:planned_for_gor_q1) }
    it { should allow_mass_assignment_of(:planned_for_gor_q2) }
    it { should allow_mass_assignment_of(:planned_for_gor_q3) }
    it { should allow_mass_assignment_of(:planned_for_gor_q4) }
  end

  describe "Validations" do
    subject { basic_setup_activity; @activity }
    it { should validate_presence_of(:data_response_id) }
    it { should validate_presence_of(:project_id) }
    it { should ensure_length_of(:name) }
    it { should validate_presence_of(:description) }
  end

  describe "update attributes" do
    context "when one implementer_split" do
      before :each do
        basic_setup_activity
        attributes = {"name"=>"dsf", "project_id"=>"#{@project.id}",
          "implementer_splits_attributes"=>
            {"0"=>{"spend"=>"10", "organization_mask"=>"#{@organization.id}",
            "budget"=>"20.0", "_destroy"=>""}
            }, "description"=>"adfasdf"}
        @activity.reload
        @activity.update_attributes(attributes).should be_true
      end

      it "should maintain the activites budget/spend cache when creating a new sub_activity" do
        @activity.implementer_splits.size.should == 1
        @activity.implementer_splits[0].organization.should == @organization
        @activity.implementer_splits[0].spend.to_f.should == 10
        @activity.implementer_splits[0].budget.to_f.should == 20
        @activity.reload
        @activity.total_spend.to_f.should == 10
        @activity.total_budget.to_f.should == 20
      end

    end

    context "when two implementer_splits" do
      before :each do
        basic_setup_implementer_split
        @implementer2 = FactoryGirl.create :organization
        @split2 = FactoryGirl.create :implementer_split, activity: @activity,
          organization: @implementer2
      end

      it "should validate duplicate implementer splits when saving nested attr" do
        attributes = {"name"=>"dsf", "description"=>"adfasdf",
          "project_id"=>"#{@project.id}",
          "implementer_splits_attributes"=>
            {"0"=>
              {"id" => "#{@split.id}",
               "organization_mask"=>"#{@organization.id}",
               "spend"=>"10", "budget"=>"20.0"},
            "1"=>
              {"id" => "#{@split2.id}",
               "organization_mask"=>"#{@organization.id}",
               "spend"=>"20", "budget"=>"40.0"},
            }}
        @activity.reload
        @activity.update_attributes(attributes).should be_false
        @activity.implementer_splits[1].errors[:base].should include "Duplicate Implementer"
        @activity.implementer_splits[0].errors[:base].should include "Duplicate Implementer"

        #spec breaks if split into two seperate specs - objects persist in memory
        attributes = {"name"=>"dsf", "description"=>"adfasdf",
          "project_id"=>"#{@project.id}",
          "implementer_splits_attributes"=>
            {"0"=>
              {"id" => "#{@split.id}",
               "organization_mask"=>"#{@organization.id}", "spend"=>"10",
               "budget"=>"20.0"},
            "1"=>
              {"id" => "#{@split2.id}",
               "organization_mask"=>"#{@implementer2.id}", "spend"=>"20",
               "budget"=>"40.0"},
            }}

        @activity.reload
        @activity.update_attributes(attributes).should be_true

        @activity.implementer_splits.size.should == 2
        @activity.implementer_splits[0].organization.should == @organization
        @activity.implementer_splits[0].spend.to_f.should == 10
        @activity.implementer_splits[0].budget.to_f.should == 20
        @activity.implementer_splits[1].organization.should == @implementer2
        @activity.implementer_splits[1].spend.to_f.should == 20
        @activity.implementer_splits[1].budget.to_f.should == 40
        @activity.reload
        @activity.total_spend.to_f.should == 30
        @activity.total_budget.to_f.should == 60
      end

    end
  end

    it "returns organization name" do
      @organization = FactoryGirl.create(:organization, name: "Organization1")
      user = FactoryGirl.create :user, organization: @organization
      @request      = FactoryGirl.create(:data_request, organization: @organization)
      @response     = @organization.latest_response
      @project      = FactoryGirl.create(:project, data_response: @response)
      @activity     = FactoryGirl.create(:activity, data_response: @response, project: @project)
      @activity.organization_name.should == "Organization1"
    end

  describe "gets budget and spend from sub activities" do
    before :each do
      basic_setup_activity
      @split = FactoryGirl.create :implementer_split, activity: @activity,
        spend: 10, budget: 25, organization: @organization
      @activity.reload; @activity.save;
    end

    it "activity.total_budget should be the total of sub activities(1)" do
      @activity.total_budget.to_f.should == 25
    end

    it "activity.total_spend should be the total of sub activities(1)" do
      @activity.total_spend.to_f.should == 10
    end

    it "refreshes the amount if the amount of the sub-activity changes" do
      @split.spend = 13; @split.budget = 29; @split.save!; @activity.reload; @activity.save;
      @activity.total_spend.to_f.should == 13
      @activity.total_budget.to_f.should == 29
    end

    describe "works with more than one sub activity" do
      before :each do
        @split1 = FactoryGirl.create :implementer_split, activity: @activity,
          spend: 100, budget: 125, organization: FactoryGirl.create(:organization)
        @activity.reload; @activity.save;
      end

      it "activity.total_budget should be the total of sub activities(2)" do
        @activity.total_budget.to_f.should == 150
      end

      it "activity.total_spend should be the total of sub activities(2)" do
        @activity.total_spend.to_f.should == 110
      end

      it "refreshes the amount if the amount of the sub-activity changes" do
        @split.spend = 20; @split.budget = 35; @split.save!; @activity.reload; @activity.save;
        @activity.total_spend.to_f.should == 120
        @activity.total_budget.to_f.should == 160
      end
    end

    it "should not allow you to set the activities budget directly" do
      expect { budget }.should raise_error
    end

    it "should not allow you to set the activities spend directly" do
      expect { spend }.should raise_error
    end
  end

  describe "deep cloning" do
    before :each do
      basic_setup_activity
      @original = @activity #for shared examples
    end

    it "should clone associated code assignments" do
      @ca = FactoryGirl.create(:code_split, activity: @activity)
      save_and_deep_clone
      @clone.code_splits.count.should == 1
      @clone.code_splits[0].code.should == @ca.code
      @clone.code_splits[0].activity.should_not == @activity
      @clone.code_splits[0].activity.should == @clone
    end

    it "should clone beneficiaries" do
      @benefs = [FactoryGirl.create(:beneficiary)]
      @activity.beneficiaries << @benefs
      save_and_deep_clone
      @clone.beneficiaries.should == @benefs
    end
  end

  describe "purposes" do
    it "should return only those codes designated as Purpose codes" do
      basic_setup_activity
      @purpose1    = FactoryGirl.create(:purpose, short_display: 'purp1')
      @purpose2    = FactoryGirl.create(:mtef_code, short_display: 'purp2')
      @input       = FactoryGirl.create(:input, short_display: 'input')
      FactoryGirl.create(:purpose_budget_split, activity: @activity,
              code: @purpose1, cached_amount: 5)
      FactoryGirl.create(:purpose_budget_split, activity: @activity,
              code: @purpose2, cached_amount: 15)
      FactoryGirl.create(:input_budget_split, activity: @activity,
              code: @input, cached_amount: 5)
      @activity.purposes.should == [@purpose1, @purpose2]
    end
  end

  describe "#locations" do
    it "returns uniq locations only from district classifications" do
      basic_setup_activity
      location1 = FactoryGirl.create(:location)
      location2 = FactoryGirl.create(:location)
      location3 = FactoryGirl.create(:location)
      location4 = FactoryGirl.create(:location)
      FactoryGirl.create(:location_budget_split, activity: @activity, code: location1)
      FactoryGirl.create(:location_budget_split, activity: @activity, code: location2)
      FactoryGirl.create(:location_spend_split, activity: @activity, code: location2)
      FactoryGirl.create(:purpose_budget_split, activity: @activity, code: location3)
      FactoryGirl.create(:purpose_spend_split, activity: @activity, code: location4)

      @activity.locations.length.should == 2
      @activity.locations.should include(location1)
      @activity.locations.should include(location2)
    end
  end
end
