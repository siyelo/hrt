require 'spec_helper'

describe DataResponse::States do
  let(:dr) { DataResponse.new }

  describe "#state_to_name" do
    it "returns 'Not Yet Started' when state is 'unstarted'" do
      dr.state_to_name('unstarted').should == 'Not Yet Started'
    end

    it "returns 'Started' when state is 'started'" do
      dr.state_to_name('started').should == 'Started'
    end

    it "returns 'Submitted' when state is 'submitted'" do
      dr.state_to_name('submitted').should == 'Submitted'
    end

    it "returns 'Rejected' when state is 'rejected'" do
      dr.state_to_name('rejected').should == 'Rejected'
    end

    it "returns 'Accepted' when state is 'accepted'" do
      dr.state_to_name('accepted').should == 'Accepted'
    end
  end

  describe "#name_to_state" do
    it "returns 'unstarted' when state is 'Not Yet Started'" do
      dr.name_to_state('Not Yet Started').should =='unstarted'
    end

    it "returns 'started' when state is 'Started'" do
      dr.name_to_state('Started').should == 'started'
    end

    it "returns 'submitted' when state is 'Submitted'" do
      dr.name_to_state('Submitted').should == 'submitted'
    end

    it "returns 'rejected' when state is 'Rejected'" do
      dr.name_to_state('Rejected').should == 'rejected'
    end

    it "returns 'accepted' when state is 'Accepted'" do
      dr.name_to_state('Accepted').should == 'accepted'
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
      request      = Factory :data_request
      organization = Factory(:organization)
      Factory :user, :organization => organization
      @response    = organization.latest_response
    end

    it "sets unstarted as default state" do
      @response.state.should == 'unstarted'
    end

    context "first project is created" do
      it "transitions from unstarted to started when first project is created" do
        @response.state.should == 'unstarted'
        Factory(:project, :data_response => @response)
        @response.state.should == 'started'
      end

      it "does not transitions back to in progress if it's in rejected state" do
        @response.state = 'rejected'
        Factory(:project, :data_response => @response)
        @response.state.should == 'rejected'
      end
    end

    context "first other cost without is created" do
      it "transitions from unstarted to started when first project is created" do
        @response.state.should == 'unstarted'
        Factory(:other_cost, :data_response => @response)
        @response.reload.state.should == 'started'
      end

      it "does not transitions back to in progress if it's in rejected state" do
        @response.state = 'rejected'
        Factory(:other_cost, :data_response => @response)
        @response.state.should == 'rejected'
      end
    end

    context "no other costs without project" do
      context "all projects are destroyed" do
        it "moves the response into unstarted state" do
          @response.state.should == 'unstarted'
          project = Factory(:project, :data_response => @response)
          @response.state.should == 'started'
          project.destroy
          @response.reload.state.should == 'unstarted'
        end
      end
    end

    context "other costs without project present" do
      it "moves the response into unstarted state" do
        @response.state.should == 'unstarted'
        project = Factory(:project, :data_response => @response)
        other_cost = Factory(:other_cost, :data_response => @response)
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
        project = Factory(:project, :data_response => @response)
        @response.state.should == 'started'
        activity1 = Factory(:activity, :data_response => @response,
                            :project => project)
        activity2 = Factory(:activity, :data_response => @response,
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
end
