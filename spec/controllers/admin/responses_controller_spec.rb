require 'spec_helper'

describe Admin::ResponsesController do
  describe "routes"  do
    [:index, :new].each do |endpoint|
      context "/admin/responses/#{endpoint} using GET" do
        before do get endpoint end
        it_should_behave_like "a protected admin endpoint"
      end
    end
  end

  context "as admin" do
    before :each do
      login_as_admin
    end

    describe "index" do
      before :each do
        pie = mock :chart, google_bar: {}
        Charts::Responses::State.should_receive(:new).once.and_return pie
        # login as admin creates 1 NR and 1 Reporting org(1 response)
        @data_response = @admin_org.responses.first
        @request1 = FactoryGirl.create(:data_request) # autocreate 1 response for first reporting org
        @org = FactoryGirl.create(:organization)
        @user = FactoryGirl.create :user, organization: @org #+2 responses
        @latest_response = @org.responses.latest_first.first
      end

      it "should return all responses for current request by default" do
        get :index
        assigns(:responses).size.should == 2
      end

      it "should return all responses" do
        get :index, filter: 'All'
        assigns(:responses).size.should == 2
      end

      it "should ignore unrecognized filters" do
        get :index, filter: 'Blah'
        assigns(:responses).size.should == 2
      end

      it "should filter by empty response" do
        get :index, filter: 'Not Started'
        assigns(:responses).size.should == 2
      end

      it "should filter by started response" do
        @latest_response.start!(@user)
        get :index, filter: 'Started'
        assigns(:responses).size.should == 1
      end

      it "should filter by rejected response" do
        @latest_response.reject!(@user)
        get :index, filter: 'Rejected'
        assigns(:responses).size.should == 1
      end

      it "should filter by submitted response" do
        @latest_response.submit!(@user)
        get :index, filter: 'Submitted'
        assigns(:responses).size.should == 1
      end

      it "should filter by complete response" do
        @latest_response.accept!(@user)
        get :index, filter: 'Accepted'
        assigns(:responses).size.should == 1
      end
    end

    it "#new" do
      get :new
      response.should be_success
    end

    describe "#create" do
      let(:fields) { {"organization_id" => "1", "data_request_id" => "1"} }
      let(:resp) {mock :response, save: true}

      it "creates OK" do
        DataResponse.should_receive(:new).with(fields).and_return resp
        post :create, data_response: fields
        flash[:notice].should == "Response was successfully created"
        response.should redirect_to(admin_responses_path)
      end

      it "flashes and renders on error" do
        resp.should_receive(:save).and_return false
        DataResponse.should_receive(:new).with(fields).and_return resp
        post :create, data_response: fields
        flash[:error].should == "Sorry, we were unable to save that response"
        response.should render_template(:new)
      end
    end

    describe "#destroy" do
      before :each do
        @org = FactoryGirl.create(:organization)
        @data_request = FactoryGirl.create(:data_request, organization: @org)
        @data_response = @data_request.reload.data_responses[0]
      end

      it "can destroy a data response" do
        post :destroy, id: @data_response.id
        flash[:notice].should == "#{@data_response.title} scheduled for deletion"
        response.should redirect_to admin_responses_path
      end
    end
  end
end
