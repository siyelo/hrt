require 'spec_helper'

include ControllerStubs

describe ResponsesController do
  describe "user permissions" do
    before :each do
      login # login as reporter
    end

    it_should_require_sysadmin_for :restart, :reject, :accept
  end

  describe "Submit" do
    before :each do
      user          = stub_logged_in_reporter
      @data_response = mock_model(DataResponse)
      @data_response.stub(:ready_to_submit?).and_return(true)
      @data_response.stub_chain(:projects, :find).and_return([])

      user.stub_chain(:data_responses, :find_by_id).and_return(@data_response)
      user.stub_chain(:organization, :data_responses, :latest_first, :first).and_return(@data_response)
      current_user = controller.stub!(:current_user).and_return(user)
    end

    it "can submit a response" do
      @data_response.stub(:state).and_return('started')
      @data_response.should_receive(:state=).with('submitted')
      @data_response.should_receive(:save!).and_return(true)

      put :submit, :id => 1

      response.should redirect_to(review_response_url(@data_response))
      flash[:notice].should == 'Successfully submitted. We will review your data and get back to you with any questions. Thank you.'
    end
  end
end
