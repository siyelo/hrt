require 'spec_helper'

include ControllerStubs

describe ProjectsController do
  describe "as a reporter" do
    before :each do
      @organization = FactoryGirl.create :organization, name: "Reporter Org"
      @data_request = FactoryGirl.create :data_request, organization: @organization
      @user = FactoryGirl.create(:reporter, organization: @organization)
      login @user
    end

    it "create a project when the data_response is accepted" do
      request.env['HTTP_REFERER'] = projects_url
      controller.stub(:current_response).and_return(mock :response, state: "submitted")
      controller.should_not_receive(:create)
      post :create,
        project: {name: "new project", description: "new description",
                     start_date: "2010-01-01", end_date: "2010-12-31",
                     budget_type: "on", currency: "USD",
                     in_flows_attributes: { "0" =>
                                               {organization_id_from: @organization.id,
                                                budget: 10, spend: 20}}}
      flash[:error].should == "Your entry has already been submitted. If you wish to further edit your entry, please contact a System Administrator"
      response.should redirect_to(request.env['HTTP_REFERER'])
    end

    it "update a project when the data_response is accepted" do
      request.env['HTTP_REFERER'] = projects_url
      @project = FactoryGirl.create(:project, data_response: @organization.latest_response)
      controller.stub(:current_response).and_return(mock :response, state: "accepted")
      controller.should_not_receive(:update)
      put :update, id: @project.id
      flash[:error].should == "Your entry has already been submitted. If you wish to further edit your entry, please contact a System Administrator"
      response.should redirect_to(request.env['HTTP_REFERER'])
    end

    it "destroy a project when the data_response is accepted" do
      request.env['HTTP_REFERER'] = projects_url
      @project = FactoryGirl.create(:project, data_response: @organization.latest_response)
      controller.stub(:current_response).and_return(mock :response, state: "submitted")
      controller.should_not_receive(:destroy)
      delete :destroy, id: @project.id
      flash[:error].should == "Your entry has already been submitted. If you wish to further edit your entry, please contact a System Administrator"
      response.should redirect_to(request.env['HTTP_REFERER'])
    end

    it "redirects to the projects index after create" do
      request        = FactoryGirl.create(:data_request, organization: @organization)
      @data_request  = request
      @data_response = @organization.latest_response
      post :create,
        project: {name: "new project", description: "new description",
                     start_date: "2010-01-01", end_date: "2010-12-31", budget_type: "on",
                     currency: "USD",
                     in_flows_attributes: { "0" => {organization_id_from: @organization.id,
                                                       budget: 10, spend: 20}}}
      response.should redirect_to projects_path
    end

    describe "nested funder management" do
      before :each do
        request      = FactoryGirl.create(:data_request, organization: @organization)
        @data_request = request
        @data_response     = @organization.latest_response
      end

      it "should create a new in-flow (eg. self implementer)" do
        post :create,
          project: {name: "new project", description: "new description",
                       start_date: "2010-01-01", end_date: "2010-12-31", budget_type: "on",
                       currency: "USD",
                       in_flows_attributes: { "0" => {organization_id_from: @organization.id,
                                                         budget: 10, spend: 20}}}
        project = Project.find_by_name('new project')
        project.should_not be_nil
        project.in_flows.should have(1).funder
        project.in_flows.first.organization.should == @organization
      end

      it "should create a new from-org when new name given in in-flows" do
        post :create,
          project: {name: "new project", description: "new description",
                       start_date: "2010-01-01", end_date: "2010-12-31", budget_type: "on",
                       currency: "USD",
                       in_flows_attributes: { "0" => {organization_id_from: "a new org plox k thx",
                                                         budget: 10, spend: 20}}}
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
        response.header["Content-Type"].should == "application/vnd.ms-excel"
        response.header["Content-Disposition"].should == "attachment; filename=import_template.xls"
      end
    end
  end

  describe "as a activity_manager" do
    before :each do
      @organization = FactoryGirl.create :organization, name: "Reporter Org"
      @user = FactoryGirl.create(:reporter, organization: @organization)
      @organization = @user.organization
      login @user
      @data_request = FactoryGirl.create(:data_request, organization: @organization)
      @data_response = @organization.latest_response
    end

    it "downloads csv workplan" do
      get :export_workplan
      response.should be_success
      response.header["Content-Type"].should == "application/vnd.ms-excel"
      filename = "#{@organization.name.split.join('_').downcase.underscore}_workplan.xls"
      response.header["Content-Disposition"].should == "attachment; filename=#{filename}"
    end
  end

  describe "Permissions" do
    context "Activity Manager" do
      before :each do
        @organization = FactoryGirl.create :organization
        @data_request = FactoryGirl.create :data_request, organization: @organization
        @user = FactoryGirl.create :activity_manager, organization: @organization
        @data_response = @organization.latest_response
        @project = FactoryGirl.create(:project, data_response: @data_response)
        login @user
        request.env['HTTP_REFERER'] = projects_url
      end

      it "disallows an activity manager to create an project" do
        controller.should_not_receive(:create)
        post :create
        flash[:error].should == "You do not have permission to edit this resource"
        response.should redirect_to(request.env['HTTP_REFERER'])
      end

      it "disallows an activity manager to update an project" do
        controller.should_not_receive(:update)
        put :update, id: @project.id
        flash[:error].should == "You do not have permission to edit this resource"
        response.should redirect_to(request.env['HTTP_REFERER'])
      end

      it "allows an activity manager to destroy an project" do
        controller.should_not_receive(:destroy)
        delete :destroy, id: @project.id
        flash[:error].should == "You do not have permission to edit this resource"
        response.should redirect_to(request.env['HTTP_REFERER'])
      end
    end

    context "Reporter and Activity Manager" do
      before :each do
        @data_request = FactoryGirl.create :data_request
        @organization = FactoryGirl.create :organization
        @user = FactoryGirl.create :user, roles: ['reporter', 'activity_manager'],
          organization: @organization
        @data_response = @organization.latest_response
        @project = FactoryGirl.create(:project, data_response: @data_response)
      end


      it "allows the editing of the organization the reporter is in" do
        login @user

        session[:return_to] = edit_project_path(@project)
        put :update, id: @project.id,
          project: { description: "thedesc" }

        flash[:error].should_not == "You do not have permission to edit this project"
        flash[:notice].should == "Project successfully updated"
        response.should redirect_to(edit_project_url(@project))
      end

      it "should not allow the editing of organization the reporter is not in" do
        request.env['HTTP_REFERER'] = projects_url
        @organization2 = FactoryGirl.create :organization
        @user.organization = @organization2
        @user.organizations << @organization
        @user.save!
        login @user
        session[:return_to] = edit_project_url(@project)
        controller.should_not_receive(:update)
        put :update, id: @project.id, response_id: @data_response.id
        response.should redirect_to(request.env['HTTP_REFERER'])
      end
    end

    context "who are sysadmins and activity managers" do
      before :each do
        @organization = FactoryGirl.create :organization
        @data_request = FactoryGirl.create :data_request, organization: @organization
        @user = FactoryGirl.create :user, roles: ['admin', 'activity_manager'],
          organization: @organization
        @data_response = @organization.latest_response
        @project = FactoryGirl.create(:project, data_response: @data_response)
        login @user
      end

      it "allows user to create project" do
        session[:return_to] = new_project_url
        post :create,
          project: { name: "new project", budget_type: "on",
                        description: "description", start_date: "09-12-2012",
                        end_date: "09-12-2013", currency: "USD",
                        "in_flows_attributes"=>{"0"=>{
                          "organization_id_from"=>"#{@organization.id}",
                          "spend"=>"120.0", "budget"=>"130.0"}}
        }

        flash[:error].should_not == "You do not have permission to edit this project"
        flash[:notice].should == "Project successfully created"
      end

      it "allows user to edit the project" do
        session[:return_to] = edit_project_url(@project)
        put :update, id: @project.id,
          project: {description: "thedesc"}

        flash[:error].should_not == "You do not have permission to edit this project"
        flash[:notice].should == "Project successfully updated"
        response.should redirect_to(edit_project_url(@project))
        @project.reload.description.should == "thedesc"
      end
    end
  end
end
