require 'spec_helper_lite'

require File.join(APP_ROOT, 'lib/response_states')

describe ResponseStates do

  describe "#name_to_state" do
    class Something
      include ResponseStates
    end

    let(:subject) { Something.new }

    it "returns 'unstarted' when state is 'Not Yet Started'" do
      subject.name_to_state('Not Yet Started').should =='unstarted'
    end

    it "returns 'started' when state is 'Started'" do
      subject.name_to_state('Started').should == 'started'
    end

    it "returns 'submitted' when state is 'Submitted'" do
      subject.name_to_state('Submitted').should == 'submitted'
    end

    it "returns 'rejected' when state is 'Rejected'" do
      subject.name_to_state('Rejected').should == 'rejected'
    end

    it "returns 'accepted' when state is 'Accepted'" do
      subject.name_to_state('Accepted').should == 'accepted'
    end
  end
end
