require File.dirname(__FILE__) + '/../spec_helper'

describe DataResponse do
  describe "Associations" do
    it { should belong_to(:organization) }
    it { should belong_to(:data_request) }
    it { should have_many(:activities) }
    it { should have_many(:other_costs).dependent(:destroy) }
    it { should have_many(:projects).dependent(:destroy) }
    it { should have_many(:implementer_splits) } # delegate destroy to project -> activity
    it { should have_many(:users_currently_completing) }
    it { should have_many(:comments).dependent(:destroy) }
  end

  describe "Validations" do
    subject { basic_setup_response; @response }
    it { should validate_presence_of(:data_request_id) }
    it { should validate_presence_of(:organization_id) }
    it { should validate_uniqueness_of(:data_request_id).scoped_to(:organization_id) }

    it "cannot assign nil state" do
      basic_setup_response
      @response.state = nil
      @response.valid?.should be_false
    end

    it "cannot assign unexisting state" do
      basic_setup_response
      @response.state = 'invalid'
      @response.valid?
      @response.errors.on(:state).should include('is not included in the list')
    end
  end

  describe "#name" do
    it "returns data_response name" do
      organization = Factory(:organization)
      request      = Factory(:data_request, :organization => organization,
                             :title => 'Data Request 1')
      response     = organization.latest_response

      response.name.should == 'Data Request 1'
    end
  end

  describe "#budget & #spend" do
    before :each do
      @organization = Factory(:organization, :currency => 'USD')
      request      = Factory(:data_request, :organization => @organization)
      @response    = @organization.latest_response
    end

    context "same currency" do
      it "returns total" do
        project      = Factory(:project, :data_response => @response)
        @activity    = Factory(:activity, :data_response => @response, :project => project)
        split1       = Factory(:implementer_split, :activity => @activity,
                               :budget => 200, :spend => 100, :organization => Factory(:organization))
        @oc1         = Factory(:other_cost, :data_response => @response, :project => project)
        split2       = Factory(:implementer_split, :activity => @activity,
                               :budget => 200, :spend => 100, :organization => Factory(:organization))
        @oc2         = Factory(:other_cost, :data_response => @response)
        split3       = Factory(:implementer_split, :activity => @activity,
                               :budget => 200, :spend => 100, :organization => Factory(:organization))
        @activity.reload; @activity.save;
        @oc1.reload; @oc1.save;
        @oc2.reload; @oc2.save;
        @response.total_budget.to_f.should == 600
        @response.total_spend.to_f.should == 300
      end
    end

    context "different currency" do
      it "returns total" do
        Money.default_bank.add_rate(:RWF, :USD, 0.5)
        Money.default_bank.add_rate(:USD, :RWF,  2)
        project      = Factory(:project, :data_response => @response, :currency => 'RWF')
        @activity1   = Factory(:activity, :data_response => @response, :project => project)
        split1        = Factory(:implementer_split, :activity => @activity1,
                               :budget => 200, :spend => 100, :organization => Factory(:organization))
        @other_cost1  = Factory(:other_cost, :data_response => @response, :project => project)
        split2        = Factory(:implementer_split, :activity => @other_cost1,
                               :budget => 200, :spend => 100, :organization => Factory(:organization))
        @other_cost2 = Factory(:other_cost, :data_response => @response)
        split        = Factory(:implementer_split, :activity => @other_cost2,
                               :budget => 200, :spend => 100, :organization => Factory(:organization))
        @activity1.reload; @activity1.save;
        @other_cost1.reload; @other_cost1.save;
        @other_cost2.reload; @other_cost2.save;
        @response.total_budget.to_f.should == 400 # RWF200 + RWF200 + USD200
        @response.total_spend.to_f.should == 200 # 50 + 50 + 100
      end
    end

  end
end
