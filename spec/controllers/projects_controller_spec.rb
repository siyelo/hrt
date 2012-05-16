require File.dirname(__FILE__) + '/../spec_helper'

include ControllerStubs

describe ProjectsController do
  describe "as a reporter" do
    before :each do
      @organization = Factory :organization, :name => "Reporter Org"
      @user = Factory.create(:reporter, :organization => @organization)
      @organization = @user.organization
      login @user
    end

    it "redirects to the projects index after create" do
      request        = Factory(:data_request, :organization => @organization)
      @data_request  = request
      @data_response = @organization.latest_response
      post :create,
        :project => {:name => "new project", :description => "new description",
        :start_date => "2010-01-01", :end_date => "2010-12-31", :currency => "USD",
        :in_flows_attributes => { "0" => {:organization_id_from => @organization.id,
          :budget => 10, :spend => 20}}}
      response.should redirect_to projects_path
    end

    describe "nested funder management" do
      before :each do
        request      = Factory(:data_request, :organization => @organization)
        @data_request = request
        @data_response     = @organization.latest_response
      end

      it "should create a new in-flow (eg. self implementer)" do
        post :create,
          :project => {:name => "new project", :description => "new description",
          :start_date => "2010-01-01", :end_date => "2010-12-31", :currency => "USD",
          :in_flows_attributes => { "0" => {:organization_id_from => @organization.id,
            :budget => 10, :spend => 20}}}
        project = Project.find_by_name('new project')
        project.should_not be_nil
        project.in_flows.should have(1).funder
        project.in_flows.first.organization.should == @organization
      end

      it "should create a new from-org when new name given in in-flows" do
        post :create,
          :project => {:name => "new project", :description => "new description",
          :start_date => "2010-01-01", :end_date => "2010-12-31", :currency => "USD",
          :in_flows_attributes => { "0" => {:organization_id_from => "a new org plox k thx",
            :budget => 10, :spend => 20}}}
        project = Project.find_by_name('new project')
        project.should_not be_nil
        project.in_flows.should have(1).funder
        new_org = Organization.find_by_name "a new org plox k thx"
        new_org.should_not be_nil
      end
    end

    describe "import / export" do
      before :each do
        @data_response = mock_model(DataResponse)
        DataResponse.stub(:find).and_return(@data_response)
      end

      it "downloads xls template" do
        data_response = mock_model(DataResponse)
        DataResponse.stub(:find).and_return(data_response)
        get :download_template
        response.should be_success
        response.header["Content-Type"].should == "application/excel"
        response.header["Content-Disposition"].should == "attachment; filename=import_template.xls"
      end
    end

    describe "Import and Save" do
      before :each do
        @data_response = mock_model(DataResponse)
        DataResponse.stub(:find).and_return(@data_response)
      end

      context "reporter" do
        it "cannot import and save using delayed_job" do
          user = stub_logged_in_reporter
          user.stub_chain(:organization, :data_responses,
                          :latest_first, :first).and_return(@data_response)

          post :import_and_save

          response.should redirect_to(root_url)
          flash[:error].should == "You must be an administrator to access that page"
        end
      end

      # TODO: stub params[:file]
      context "sysadmin" do
        it "can import and save using delayed_job" do
          user = stub_logged_in_sysadmin
          user.stub_chain(:organization, :data_responses,
                          :latest_first, :first).and_return(@data_response)
          DataResponse.stub(:find_by_id).with('1').and_return(@data_response)
          post :import_and_save

          response.should redirect_to(projects_path)
          flash[:error].should == "Please select a file to upload"
        end
      end
    end

  end

  describe "as a activity_manager" do
    before :each do
      @organization = Factory :organization, :name => "Reporter Org"
      @user = Factory.create(:reporter, :organization => @organization)
      @organization = @user.organization
      login @user
      @data_response = mock_model(DataResponse)
      @data_request = mock_model(DataRequest)
      DataResponse.stub(:find).and_return(@data_response)
    end

    describe "import / export" do
      it "downloads csv workplan" do
        @data_request.stub(:id).and_return(1)
        @data_response.stub(:organization).and_return(@organization)
        @data_response.stub_chain(:projects, :sorted).and_return([])
        @data_response.stub_chain(:projects, :empty?).and_return(true)
        @data_response.stub(:request).and_return(@data_request)
        @organization.stub(:name).and_return('Org Name')

        workplan = Reports::ActivityManagerWorkplan.new(@data_response)
        workplan.stub(:data).and_return(StringIO.new('dummy,xls,header'))
        get :export_workplan
        response.should be_success
        response.header["Content-Type"].should == "application/excel"
        filename = "#{@organization.name.split.join('_').downcase.underscore}_workplan.xls"
        response.header["Content-Disposition"].should == "attachment; filename=#{filename}"
      end
    end
  end

  describe "Permissions" do
    context "Activity Manager" do
      before :each do
        @organization = Factory :organization
        @data_request = Factory :data_request, :organization => @organization
        @user = Factory :activity_manager, :organization => @organization
        @data_response = @organization.latest_response
        @project = Factory(:project, :data_response => @data_response)
        login @user
        request.env['HTTP_REFERER'] = projects_url
      end

      it "disallows an activity manager to create an project" do
        controller.should_not_receive(:create)
        post :create
        flash[:error].should == "You do not have permission to edit this resource"
        response.should redirect_to(projects_url)
      end

      it "disallows an activity manager to update an project" do
        controller.should_not_receive(:update)
        put :update, :id => @project.id
        flash[:error].should == "You do not have permission to edit this resource"
        response.should redirect_to(projects_url)
      end

      it "allows an activity manager to destroy an project" do
        controller.should_not_receive(:destroy)
        delete :destroy, :id => @project.id
        flash[:error].should == "You do not have permission to edit this resource"
        response.should redirect_to(projects_url)
      end
    end

    context "Reporter and Activity Manager" do
      before :each do
        @data_request = Factory :data_request
        @organization = Factory :organization
        @user = Factory :user, :roles => ['reporter', 'activity_manager'],
          :organization => @organization
        @data_response = @organization.latest_response
        @project = Factory(:project, :data_response => @data_response)
      end

      it "allows the editing of the organization the reporter is in" do
        login @user

        session[:return_to] = edit_project_path(@project)
        put :update, :id => @project.id,
          :project => { :description => "thedesc" }

        flash[:error].should_not == "You do not have permission to edit this project"
        flash[:notice].should == "Project successfully updated"
        response.should redirect_to(edit_project_url(@project))
      end

      it "should not allow the editing of organization the reporter is not in" do
        request.env['HTTP_REFERER'] = projects_url
        @organization2 = Factory :organization
        @user.organization = @organization2
        @user.organizations << @organization
        @user.save!
        login @user
        session[:return_to] = edit_project_url(@project)
        controller.should_not_receive(:update)
        put :update, :id => @project.id, :response_id => @data_response.id
        response.should redirect_to(projects_url)
      end
    end

    context "who are sysadmins and activity managers" do
      before :each do
        @organization = Factory :organization
        @data_request = Factory :data_request, :organization => @organization
        @user = Factory :user, :roles => ['admin', 'activity_manager'],
          :organization => @organization
        @data_response = @organization.latest_response
        @project = Factory(:project, :data_response => @data_response)
        login @user
      end

      it "allows user to create project" do
        session[:return_to] = new_project_url
        post :create,
          :project => { :name => "new project", :description => "description",
            :start_date => "09-12-2012", :end_date => "09-12-2013", :currency => "USD",
            "in_flows_attributes"=>{"0"=>{
              "organization_id_from"=>"#{@organization.id}",
             "spend"=>"120.0", "budget"=>"130.0"}}
          }

        flash[:error].should_not == "You do not have permission to edit this project"
        flash[:notice].should == "Project successfully created"
      end

      it "allows user to edit the project" do
        session[:return_to] = edit_project_url(@project)
        put :update, :id => @project.id,
          :project => {:description => "thedesc", :project_id => @project.id}

        flash[:error].should_not == "You do not have permission to edit this project"
        flash[:notice].should == "Project successfully updated"
        response.should redirect_to(edit_project_url(@project))
        @project.reload.description.should == "thedesc"
      end
    end
  end
end
