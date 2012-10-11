require File.dirname(__FILE__) + '/../../spec_helper'

describe OtherCost do
  describe "Associations" do
    it { should belong_to :data_response }
    it { should belong_to :project }
    it { should have_and_belong_to_many :beneficiaries }
    it { should have_many :implementer_splits }
    it { should have_many :code_splits }
    it { should have_many :location_budget_splits }
    it { should have_many :location_spend_splits }
  end

  describe "Attributes" do
    it { should allow_mass_assignment_of(:name) }
    it { should allow_mass_assignment_of(:description) }
    it { should allow_mass_assignment_of(:project_id) }
    it { should allow_mass_assignment_of(:beneficiary_ids) }
    it { should allow_mass_assignment_of(:organization_ids) }
  end

  describe "Validations" do
    subject { basic_setup_other_cost; @other_cost }
    it { should validate_presence_of(:name) }
  end

  describe "classified?" do
    before :each do
      @organization = FactoryGirl.create(:organization)
      user = FactoryGirl.create :user, organization: @organization
      @request      = FactoryGirl.create(:data_request, organization: @organization)
      @response     = @organization.latest_response
      @project      = FactoryGirl.create(:project, data_response: @response)
      @activity     = FactoryGirl.create(:other_cost_fully_coded,
                              data_response: @response, project: @project)
      @split1 = FactoryGirl.create(:implementer_split, activity: @activity,
                        organization: @organization, budget: 50, spend: 40)

      @activity.stub(:location_budget_splits_valid?) { true }
      @activity.stub(:location_spend_splits_valid?) { true }
      @activity.save
      @activity.reload
    end

    it "is not classified when only locations are classified" do
      @activity.budget_classified?.should be_false
      @activity.spend_classified?.should be_false
      @activity.classified?.should be_false
    end

    it "is classified when inputs and locations are classified" do
      @activity.stub(:input_budget_splits_valid?) { true }
      @activity.stub(:input_spend_splits_valid?) { true }
      @activity.budget_classified?.should be_true
      @activity.spend_classified?.should be_true
      @activity.classified?.should be_true
    end

    it "is classified? when both budget and spend are classified" do
      @activity.stub(:budget_classified?) { true }
      @activity.stub(:spend_classified?) { true }
      @activity.classified?.should be_true
    end

    describe "currency" do
      it "returns data response currency if other cost without a project" do
        request      = FactoryGirl.create :data_request
        organization = FactoryGirl.create(:organization, currency: 'EUR')
        FactoryGirl.create :user, organization: organization
        response     = organization.latest_response
        oc = FactoryGirl.create(:other_cost, project: nil, data_response: response)
        oc.currency.should.eql? 'EUR'
      end

      it "returns project currency if other cost has a project" do
        request      = FactoryGirl.create :data_request
        organization = FactoryGirl.create(:organization)
        FactoryGirl.create :user, organization: organization
        response     = organization.latest_response
        project      = FactoryGirl.create(:project, data_response: response, currency: 'USD')
        oc = FactoryGirl.create(:other_cost, data_response: response, project: project)

        oc.currency.should.eql? 'USD'
      end
    end
  end

  describe "<=>" do
    it "sorts by name" do
      oc = OtherCost.new(name: "arojjy")
      oc1 = OtherCost.new(name: "projjy")

      [oc1, oc].sort.should == [oc, oc1]
    end
  end
end
