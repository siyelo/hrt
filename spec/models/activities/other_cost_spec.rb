require File.dirname(__FILE__) + '/../../spec_helper'

describe OtherCost do
  describe "Associations" do
    it { should belong_to :data_response }
    it { should belong_to :project }
    it { should have_and_belong_to_many :beneficiaries }
    it { should have_many :implementer_splits }
    it { should have_many :code_splits }
    it { should have_many :purpose_budget_splits }
    it { should have_many :input_budget_splits }
    it { should have_many :location_budget_splits }
    it { should have_many :purpose_spend_splits }
    it { should have_many :input_spend_splits }
    it { should have_many :location_spend_splits }
  end

  describe "Attributes" do
    it { should allow_mass_assignment_of(:name) }
    it { should allow_mass_assignment_of(:description) }
    it { should allow_mass_assignment_of(:project_id) }
    it { should allow_mass_assignment_of(:beneficiary_ids) }
    it { should allow_mass_assignment_of(:approved) }
    it { should allow_mass_assignment_of(:organization_ids) }
  end

  describe "Validations" do
    subject { basic_setup_other_cost; @other_cost }
    it { should validate_presence_of(:name) }
  end

  describe "classified?" do
    before :each do
      @organization = Factory(:organization)
      user = Factory :user, :organization => @organization
      @request      = Factory(:data_request, :organization => @organization)
      @response     = @organization.latest_response
      @project      = Factory(:project, :data_response => @response)
      @activity     = Factory(:other_cost_fully_coded,
                              :data_response => @response, :project => @project)
      @split1 = Factory(:implementer_split, :activity => @activity,
                        :organization => @organization, :budget => 50, :spend => 40)

      @activity.stub(:location_budget_splits_valid?) { true }
      @activity.stub(:location_spend_splits_valid?) { true }
      @activity.save
      @activity.reload
    end

    it "is classified? when only locations are classified" do
      @activity.location_budget_splits_valid?.should == true
      @activity.budget_classified?.should == true
      @activity.location_spend_splits_valid?.should == true
      @activity.spend_classified?.should == true
      @activity.classified?.should be_true
    end

    it "is classified? when both budget and spend are classified" do
      @activity.stub(:budget_classified?) { true }
      @activity.stub(:spend_classified?) { true }
      @activity.classified?.should be_true
    end

    describe "currency" do
      it "returns data response currency if other cost without a project" do
        request      = Factory :data_request
        organization = Factory(:organization, :currency => 'EUR')
        Factory :user, :organization => organization
        response     = organization.latest_response
        oc = Factory(:other_cost, :project => nil, :data_response => response)
        oc.currency.should.eql? 'EUR'
      end

      it "returns project currency if other cost has a project" do
        request      = Factory :data_request
        organization = Factory(:organization)
        Factory :user, :organization => organization
        response     = organization.latest_response
        project      = Factory(:project, :data_response => response, :currency => 'USD')
        oc = Factory(:other_cost, :data_response => response, :project => project)

        oc.currency.should.eql? 'USD'
      end
    end
  end

  describe "<=>" do
    it "sorts by name" do
      oc = OtherCost.new(:name => "arojjy")
      oc1 = OtherCost.new(:name => "projjy")

      [oc1, oc].sort.should == [oc, oc1]
    end
  end
end
