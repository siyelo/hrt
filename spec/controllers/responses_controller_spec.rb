require 'spec_helper'

include ControllerStubs

describe ResponsesController do
  describe "user permissions" do
    before :each do
      login # login as reporter
    end

    it_should_require_sysadmin_for :reject, :accept
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
      @data_response.should_receive(:submit!).and_return(true)

      put :submit, :id => 1

      response.should redirect_to(review_response_url(@data_response))
      flash[:notice].should == 'Successfully submitted. We will review your data and get back to you with any questions. Thank you.'
    end
  end

  describe "#Accept/Reject Responses" do
    describe "Activity Managers" do
      before :each do
        user = stub_logged_in_activity_manager
        @data_response = mock_model(DataResponse, id: 999)
        @data_response.stub(:state).and_return('submitted')
        @data_response.stub_chain(:organization, :users).and_return([])
        @data_response.stub_chain(:projects, :find).and_return([])
        controller.stub(:load_response_from_id).and_return(@data_response)
        user.stub_chain(:data_responses, :find_by_id).and_return(@data_response)
        user.stub_chain(:organization, :data_responses, :latest_first, :first).
          and_return(@data_response)
        current_user = controller.stub!(:current_user).and_return(user)
        request.env['HTTP_REFERER'] = dashboard_path(response_id: @data_response.id)
      end

      it "can reject responses" do
        DataResponse.should_receive(:find).with('999').and_return(@data_response)
        @data_response.should_receive(:reject!).and_return(true)
        get :reject, id: 999
        flash[:notice].should == "Response was successfully rejected"
        response.should redirect_to(dashboard_path(response_id: @data_response.id))
      end

      it "can accept responses" do
        DataResponse.should_receive(:find).with('999').and_return(@data_response)
        @data_response.should_receive(:accept!).and_return(true)
        get :accept, id: 999
        flash[:notice].should == "Response was successfully accepted"
        response.should redirect_to(dashboard_path(response_id: @data_response.id))
      end
    end

    describe "Reporters" do
      before :each do
        user = stub_logged_in_reporter
        @data_response = mock_model(DataResponse, id: 999)
        @data_response.stub(:state).and_return('submitted')
        @data_response.stub_chain(:organization, :users).and_return([])
        @data_response.stub_chain(:projects, :find).and_return([])
        controller.stub(:load_response_from_id).and_return(@data_response)
        user.stub_chain(:data_responses, :find_by_id).and_return(@data_response)
        user.stub_chain(:organization, :data_responses, :latest_first, :first).
          and_return(@data_response)
        current_user = controller.stub!(:current_user).and_return(user)
        request.env['HTTP_REFERER'] = dashboard_path(response_id: @data_response.id)
      end

      it "cannot reject responses" do
        controller.should_not_receive(:reject)
        get :reject, id: 999
        response.should redirect_to(root_url)
      end

      it "cannot accept responses" do
        controller.should_not_receive(:accept)
        get :accept, id: 999
        response.should redirect_to(root_url)
      end
    end
  end
end
