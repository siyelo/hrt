require File.dirname(__FILE__) + '/../spec_helper'

describe DataResponse do
  describe "Associations" do
    it { should belong_to(:organization) }
    it { should belong_to(:data_request) }
    it { should have_many(:activities) }
    it { should have_many(:other_costs).dependent(:destroy) }
    it { should have_many(:projects).dependent(:destroy) }
    it { should have_many(:implementer_splits) } # delegate destroy to project -> activity
    it { should have_many(:comments).dependent(:destroy) }
  end

  it { should allow_mass_assignment_of(:organization_id) }
  it { should allow_mass_assignment_of(:data_request_id) }

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
      request      = Factory(:data_request, :title => 'Data Request 1')
      organization = Factory :organization
      Factory :user, :organization => organization
      response     = organization.latest_response
      response.name.should == organization.name
    end
  end

  describe "#budget & #spend" do
    before :each do
      basic_setup_response
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

  describe "by_state" do
    before :each do
      user = Factory :user
      @response_org = user.organization
      @request1     = Factory(:data_request, :organization => @response_org)
      @response1    = @response_org.latest_response
      @request2     = Factory(:data_request, :organization => @response_org)
      @response2    = @response_org.latest_response
    end

    it "returns responses by states" do
      DataResponse.with_request(@request1).with_state('started').should be_empty
      DataResponse.with_request(@request2).with_state('started').should be_empty
      DataResponse.with_request(@request1).with_state('rejected').should be_empty
      DataResponse.with_request(@request2).with_state('rejected').should be_empty

      @response1.state = 'started'
      @response1.save

      DataResponse.with_request(@request1).with_state('started').should == [@response1]
      DataResponse.with_request(@request2).with_state('started').should be_empty
      DataResponse.with_request(@request1).with_state('rejected').should be_empty
      DataResponse.with_request(@request2).with_state('rejected').should be_empty

      @response2.state = 'rejected'
      @response2.save

      DataResponse.with_request(@request1).with_state('started').should == [@response1]
      DataResponse.with_request(@request2).with_state('started').should be_empty
      DataResponse.with_request(@request1).with_state('rejected').should be_empty
      DataResponse.with_request(@request2).with_state('rejected').should == [@response2]
    end
  end

  describe "Callbacks" do
    before :each do
      basic_setup_activity
    end

    it "sysadmin unapproves response if it's rejected" do
      @activity.approved = true
      @activity.save!

      @response.reject!
      @response.reload.state.should == 'rejected'
      @activity.reload.approved.should be_false
    end

    it "activity manager unapproves response if it's rejected" do
      @activity.am_approved = true
      @activity.save!

      @response.reject!
      @response.reload.state.should == 'rejected'
      @activity.reload.am_approved.should be_false
    end
  end
end
