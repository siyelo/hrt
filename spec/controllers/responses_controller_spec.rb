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
        controller.should_receive(:load_response_from_id).and_return(@data_response)
        @data_response.should_receive(:reject!).and_return(true)
        get :reject, id: 999
        flash[:notice].should == "Response was successfully rejected"
        response.should redirect_to(dashboard_path(response_id: @data_response.id))
      end

      it "can accept responses" do
        controller.should_receive(:load_response_from_id).and_return(@data_response)
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

  context "as a reporter" do
    before :each do
      @req = FactoryGirl.create :data_request
      @reporter = FactoryGirl.create :reporter
      @data_response = mock :data_response
      @report = mock :response_overview
      login @reporter
      controller.stub(:find_response).with("999").and_return @data_response
    end

    it "should present an error if type is not specified" do
      get :generate_overview, id: 999
      flash[:error].should == "Report could not be generated. Please try again."
    end

    it "should generate the report (spend)" do
      Reports::Detailed::ResponseOverview.stub(:new).
        with(@data_response, 'spend', 'xls').and_return @report
      @report.should_receive(:generate_report_for_download).once.and_return(true)
      get :generate_overview, id: 999, type: 'spend'
      flash[:notice].should include "The report is being generated"
    end

    it "should generate the report (budget)" do
      Reports::Detailed::ResponseOverview.stub(:new).
        with(@data_response, 'budget', 'xls').and_return @report
      @report.should_receive(:generate_report_for_download).once.and_return(true)
      get :generate_overview, id: 999, type: 'budget'
      flash[:notice].should include "The report is being generated"
    end

    it "should present an error if type is not specified" do
      get :download_overview, id: 999
      flash[:error].should == "Report could not be downloaded. Please try again."
    end

    it "should download the report (spend)" do
      @data_response.should_receive('expenditure_overview_file_name').
        and_return('yes')
      @data_response.should_receive('private_expenditure_overview_url').
        and_return(root_url)
      get :download_overview, id: 999, type: 'spend'
      response.should redirect_to root_url
    end

    it "should generate the report if file isn't available for download" do
      Reports::Detailed::ResponseOverview.stub(:new).
        with(@data_response, 'spend', 'xls').and_return @report
      @report.should_receive(:generate_report_for_download).once.and_return(true)
      @data_response.should_receive('expenditure_overview_file_name').
        and_return(nil)
      get :download_overview, id: 999, type: 'spend'
      response.should redirect_to reports_path
    end
  end
end
