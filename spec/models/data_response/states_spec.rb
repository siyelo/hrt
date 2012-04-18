require 'spec_helper'

describe DataResponse::States do
  class DRTest
    include DataResponse::States
  end

  let(:dr) { DRTest.new }

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
end
