require 'spec_helper'

describe DataResponse::States do
  let(:dr) { DataResponse.new }

  describe "constants" do
    DataResponse::STATES.should == ['unstarted', 'started', 'rejected',
                                    'submitted', 'accepted']
  end

  describe "#state_to_name" do
    it "returns 'Not Yet Started' when state is 'unstarted'" do
      dr.state = 'unstarted'
      dr.state_to_name.should == 'Not Yet Started'
    end

    it "returns 'Started' when state is 'started'" do
      dr.state = 'started'
      dr.state_to_name.should == 'Started'
    end

    it "returns 'Submitted' when state is 'submitted'" do
      dr.state = 'submitted'
      dr.state_to_name.should == 'Submitted'
    end

    it "returns 'Rejected' when state is 'rejected'" do
      dr.state = 'rejected'
      dr.state_to_name.should == 'Rejected'
    end

    it "returns 'Accepted' when state is 'accepted'" do
      dr.state = 'accepted'
      dr.state_to_name.should == 'Accepted'
    end
  end

  DataResponse::STATES.each do |state_name|
    describe "##{state_name}?" do
      it "returns true if state is #{state_name}" do
        dr.state = state_name
        dr.send(:"#{state_name}?").should be_true
      end

      it "returns false if state is not started" do
        dr.state = 'invalid'
        dr.send(:"#{state_name}?").should be_false
      end
    end
  end

  describe "State machine" do
    before :each do
      request      = FactoryGirl.create :data_request
      organization = FactoryGirl.create(:organization)
      FactoryGirl.create :user, :organization => organization
      @response    = organization.latest_response
    end

    it "sets unstarted as default state" do
      @response.state.should == 'unstarted'
    end

    context "first project is created" do
      it "transitions from unstarted to started when first project is created" do
        @response.state.should == 'unstarted'
        project = FactoryGirl.create(:project, :data_response => @response)
        @response.state.should == 'started'
      end

      it "does not transitions back to in progress if it's in rejected state" do
        @response.state = 'rejected'
        FactoryGirl.create(:project, :data_response => @response)
        @response.state.should == 'rejected'
      end
    end

    context "first other cost without is created" do
      it "transitions from unstarted to started when first project is created" do
        @response.state.should == 'unstarted'
        split = FactoryGirl.create(:implementer_split, :organization => FactoryGirl.create(:organization))
        other_cost = FactoryGirl.create(:other_cost,
                             :data_response => @response,
                             :implementer_splits => [split])
        @response.reload.state.should == 'started'
      end

      it "does not transitions back to in progress if it's in rejected state" do
        @response.state = 'rejected'
        FactoryGirl.create(:other_cost, :data_response => @response)
        @response.state.should == 'rejected'
      end
    end

    context "no other costs without project" do
      context "all projects are destroyed" do
        it "moves the response into unstarted state" do
          @response.state.should == 'unstarted'
          project = FactoryGirl.create(:project, :data_response => @response)
          @response.state.should == 'started'
          project.destroy
          @response.reload.state.should == 'unstarted'
        end
      end
    end

    context "other costs without project present" do
      it "moves the response into unstarted state" do
        @response.state.should == 'unstarted'
        project = FactoryGirl.create(:project, :data_response => @response)
        other_cost = FactoryGirl.create(:other_cost, :data_response => @response)
        @response.state.should == 'started'
        project.destroy
        @response.reload.state.should == 'started'
        other_cost.destroy
        @response.reload.state.should == 'unstarted'
      end
    end

    context "response is submitted and activity is deleted" do
      it "moves the response into started state" do
        @response.state.should == 'unstarted'
        project = FactoryGirl.create(:project, :data_response => @response)
        @response.state.should == 'started'
        activity1 = FactoryGirl.create(:activity, :data_response => @response,
                            :project => project)
        activity2 = FactoryGirl.create(:activity, :data_response => @response,
                            :project => project)
        @response.state = 'submitted'
        @response.save!
        @response.state.should == 'submitted'
        activity1.destroy
        @response.reload.state.should == 'submitted'
        activity2.destroy
        @response.reload.state.should == 'started'
      end
    end

    describe "#submittable?" do
      it "can be submitted when is started" do
        @response.state = 'started'
        @response.submittable?.should be_true
      end

      it "can be submitted when is rejected" do
        @response.state = 'rejected'
        @response.submittable?.should be_true
      end

      it "cannot be submitted when is unstarted" do
        @response.state = 'unstarted'
        @response.submittable?.should be_false
      end

      it "cannot be submitted when is submitted" do
        @response.state = 'submitted'
        @response.submittable?.should be_false
      end

      it "cannot be submitted when is approved" do
        @response.state = 'approved'
        @response.submittable?.should be_false
      end
    end
  end

  it "returns the lower of 2 states" do
    DataResponse::States.lower_state('unstarted', 'started').should == 'unstarted'
    DataResponse::States.lower_state('started', 'rejected').should == 'started'
    DataResponse::States.lower_state('rejected', 'submitted').should == 'rejected'
    DataResponse::States.lower_state('submitted', 'accepted').should == 'submitted'

    DataResponse::States.lower_state('started', 'unstarted').should == 'unstarted'
    DataResponse::States.lower_state('rejected', 'submitted').should == 'rejected'
    DataResponse::States.lower_state('submitted', 'started').should == 'started'
    DataResponse::States.lower_state('unstarted', 'accepted').should == 'unstarted'
  end

  it "returns the other response state if response state is unstarted" do
    DataResponse::States.merged_response_state('unstarted', 'started').should == 'started'
    DataResponse::States.merged_response_state('started', 'unstarted').should == 'started'
    DataResponse::States.merged_response_state('submitted', 'rejected').should == 'rejected'
  end
end
