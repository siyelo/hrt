require File.dirname(__FILE__) + '/../spec_helper'

describe ActivitiesController do
  describe "Requesting Activity endpoints as visitor" do
    before :each do
      basic_setup_project_for_controller
    end
    controller_name :activities

    context "RESTful routes" do
      context "Requesting /activities/new using GET" do
        before do get :new end
        it_should_behave_like "a protected endpoint"
      end

      context "Requesting /activities/1/approve using POST" do
        before do
          @activity = Factory(:activity, :data_response => @data_response, :project => @project)
          post :sysadmin_approve, :id => @activity.id
        end
        it_should_behave_like "a protected endpoint"
      end

      context "Requesting /activities using POST" do
        before do
          params = { :name => 'title', :description =>  'descr'}
          @activity = Factory(:activity, params.merge(:data_response => @data_response,
                                                      :project => @project) )
          @activity.stub!(:save).and_return(true)
          post :create, :activity =>  params
        end
        it_should_behave_like "a protected endpoint"
      end

      context "Requesting /activities/1 using PUT" do
        before do
          params = { :name => 'title', :description =>  'descr'}
          @activity = Factory(:activity, params.merge(:data_response => @data_response,
                                                      :project => @project) )
          @activity.stub!(:save).and_return(true)
          put :update, { :id => @activity.id }.merge(params)
        end
        it_should_behave_like "a protected endpoint"
      end

      context "Requesting /activities/1 using DELETE" do
        before do
          @activity = Factory(:activity, :data_response => @data_response, :project => @project)
          delete :destroy, :id => @activity.id
        end
        it_should_behave_like "a protected endpoint"
      end
    end
  end

  describe "Requesting Activity endpoints as a reporter" do
    controller_name :activities

    before :each do
      basic_setup_implementer_split_for_controller
      login @user
    end

    it "Requesting /activities/1/sysadmin_approve using POST requires admin to approve an activity" do
      post :sysadmin_approve, :id => @activity.id
      flash[:error].should == "You must be an administrator to access that page"
    end
  end

  describe "Permissions" do
    context "Activity Manager" do
      before :each do
        basic_setup_implementer_split_for_controller
        @user.roles = ['activity_manager']
        login @user
        @activity = Factory(:activity, :data_response => @data_response, :project => @project)
        request.env['HTTP_REFERER'] = edit_activity_path(@activity,
                                        :response_id => @activity.response.id)
      end

      it "disallows creation of an activity" do
        controller.should_not_receive(:create)
        post :create
        flash[:error].should == "You do not have permission to edit this resource"
        response.should redirect_to(edit_activity_path(@activity))
      end

      it "disallows updating of an activity" do
        controller.should_not_receive(:create)
        put :update, :id => @activity.id
        flash[:error].should == "You do not have permission to edit this resource"
        response.should redirect_to(edit_activity_path(@activity))
      end

      it "disallows destroying of an activity" do
        controller.should_not_receive(:create)
        delete :destroy, :id => @activity.id
        flash[:error].should == "You do not have permission to edit this resource"
        response.should redirect_to(edit_activity_path(@activity))
      end
    end

    context "Reporter and Activity Manager" do
      before :each do
        basic_setup_implementer_split_for_controller
      end

      it "allows the activity editing in the organization the reporter is in" do
        @user.roles = ['reporter', 'activity_manager']
        login @user

        session[:return_to] = edit_activity_path(@activity)
        put :update, :id => @activity.id,
          :activity => {:description => "thedesc", :project_id => @project.id}

        flash[:error].should_not == "You do not have permission to edit this activity"
        flash[:notice].should == "Activity was successfully updated."
        response.should redirect_to(edit_activity_url(@activity))
      end

      it "should not allow the editing of organization the reporter is not in" do
        request.env['HTTP_REFERER'] = edit_activity_path(@activity,
                                        :response_id => @activity.response.id)
        @organization2 = Factory :organization, :name => "organization2"
        @user2 = Factory :user, :roles => ['reporter', 'activity_manager'],
          :organization => @organization2
        @user2.organizations << @organization
        login @user2

        controller.should_not_receive(:update)
        put :update, :id => @activity.id, :response_id => @activity.data_response.id
        flash[:error].should == "You do not have permission to edit this resource"
        response.should redirect_to(edit_activity_path(@activity, :response_id => @data_response.id))
      end
    end

    context "Sysadmins and Activity Managers" do
      before :each do
        @data_request = Factory :data_request
        @organization = Factory :organization
        @user = Factory :user, :roles => ['admin', 'activity_manager'],
          :organization => @organization
        @data_response = @organization.latest_response
        @project = Factory(:project, :data_response => @data_response)
        @activity = Factory :activity, :project => @project,
          :data_response => @data_response, :am_approved => false
        login @user
      end

      it "should allow them to create an activity" do
        @activity.delete
        session[:return_to] = new_activity_url
        post :create,
          :activity => {:project_id => '-1', :name => "new activity", :description => "description",
            "implementer_splits_attributes"=>
        {"0"=> {"updated_at" => Time.now, "spend"=>"2", "data_response_id"=>"#{@data_response.id}",
          "organization_mask"=>"#{@organization.id}", "budget"=>"4"}}}

        flash[:error].should_not == "You do not have permission to edit this activity"
        flash[:notice].should match("Activity was successfully created.")
      end

      it "should allow them to edit the activity" do
        session[:return_to] = edit_activity_url(@activity)
        put :update, :id => @activity.id,
          :activity => {:description => "thedesc", :project_id => @project.id}

        flash[:error].should_not == "You do not have permission to edit this activity"
        flash[:notice].should == "Activity was successfully updated."
        response.should redirect_to(edit_activity_url(@activity))
        @activity.reload.description.should == "thedesc"
      end
    end
  end

  describe "Update / Create" do
    before :each do
      @data_request = Factory :data_request
      @organization = Factory(:organization)
      @user = Factory(:reporter, :organization => @organization)
      @data_response = @organization.latest_response
      @project = Factory(:project, :data_response => @data_response)
      @activity = Factory(:activity, :project => @project,
                          :data_response => @data_response, :am_approved => false)
      @project.reload
      login @user
    end

    it "should allow a project to be created automatically on update" do
      #if the project_id is -1 then the controller should create a new project with name, start date and end date equal to that of the activity
      put :update, :id => @activity.id,
        :activity => {:project_id => '-1', :name => @activity.name}
      @activity.reload
      @activity.project.name.should == @activity.name
      @activity.project.in_flows.count.should == 1
      @activity.project.in_flows.first.budget.should be_nil
      @activity.project.in_flows.first.spend.should be_nil
      @activity.project.in_flows.first.valid?.should == false
    end

    it "should allow a project to be created automatically on create" do
      #if the project_id is -1 then the controller should create a new project with name, start date and end date equal to that of the activity
      post :create,
        :activity => {:project_id => '-1', :name => "new activity",
          :description => "description", "data_response_id"=>"#{@data_response.id}",
          "implementer_splits_attributes"=>
          {"0"=> {"updated_at" => Time.now, "spend"=>"2",
                  "data_response_id" => "#{@data_response.id}",
          "organization_mask"=>"#{@organization.id}", "budget"=>"4"}}}
      response.should be_redirect
      @new_activity = Activity.find_by_name('new activity')
      @new_activity.project.name.should == @new_activity.name
    end

    it "should assign the activity to an existing project if a project exists with the same name as the activity" do
      put :update, :id => @activity.id,
        :activity => {:name => @project.name, :project_id => '-1'}
      @activity.reload
      @activity.project.name.should == @project.name
    end

    it "should allow a reporter to update an activity if it's not am approved" do
      put :update, :id => @activity.id,
        :activity => {:description => "thedesc", :project_id => @project.id}
      @activity.reload
      @activity.description.should == "thedesc"
    end

    it "should not allow a reporter to update a project once it has been am_approved" do
      @activity.am_approved = true
      @activity.save
      put :update, :id => @activity.id,
        :activity => {:description => "meh", :project_id => @project.id}
      @activity.reload
      @activity.description.should_not == "meh"
      flash[:error].should == "Activity was already approved by #{@activity.user.try(:full_name)} (#{@activity.user.try(:email)}) on #{@activity.am_approved_date}"
    end

    it "redirects to the location classifications page when Save & Add Locations is clicked" do
      @data_request.save
      put :update, :activity => { :name => "new name" }, :id => @activity.id,
        :commit => 'Save & Add Locations >'
      response.should redirect_to edit_activity_path(@project.activities.first, :mode => 'locations')
    end

    it "redirects to the purpose classifications page when Save & Add Purposes is clicked" do
      @data_request.save
      put :update, :activity => { :name => "new name" }, :id => @activity.id,
        :commit => 'Save & Add Purposes >'
      response.should redirect_to edit_activity_path(@project.activities.first, :mode => 'purposes')
    end
    it "redirects to the input classifications page when Save & Add Inputs is clicked" do
      @data_request.save
      put :update, :activity => { :name => "new name" }, :id => @activity.id,
        :commit => 'Save & Add Inputs >'
      response.should redirect_to edit_activity_path(@project.activities.first, :mode => 'inputs')
    end
    it "redirects to the output classifications page when Save & Add Targets is clicked" do
      @data_request.save
      put :update, :activity => { :name => "new name" }, :id => @activity.id,
        :commit => 'Save & Add Targets >'
      response.should redirect_to edit_activity_path(@project.activities.first, :mode => 'outputs')
    end

    it "should NOT approve the project as a reporter" do
      put :activity_manager_approve, :id => @activity.id, :approve => true
      @activity.reload
      @activity.am_approved.should be_false
    end

    it "should approve the project as an activity manager" do
      manager = Factory :activity_manager, :organization => @organization
      login manager
      put :activity_manager_approve, :id => @activity.id, :approve => true
      @activity.reload
      @activity.am_approved.should be_true
      @activity.user.should == manager
    end
  end

  describe "pagination" do
    before :each do
      @data_request = Factory :data_request
      @organization = Factory :organization
      @user = Factory(:reporter, :organization => @organization)
      @data_response = @organization.latest_response
      @project = Factory(:project, :data_response => @data_response)
      @activity = Factory(:activity, :project => @project,
                          :data_response => @data_response, :am_approved => false)
      @project.reload
      login @user
    end

    it "should paginate implementer splits" do
      @split = Factory(:implementer_split, :activity => @activity,
                       :organization => @organization)
      @activity.reload
      get :edit, :id => @activity.id
      assigns(:split_errors).should be_nil
      assigns(:splits).should == @activity.implementer_splits
      assigns(:splits).total_pages == 1
    end

    it "should not paginate implementer splits when there are errors" do
      post :update, :id => @activity.id,
        :activity => {:project_id => @project.id, :name => "new activity", :description => "description",
          "implementer_splits_attributes"=>
      {"0"=> {"updated_at" => Time.now, "spend"=>"",
        "organization_mask"=>"#{@organization.id}", "budget"=>""}}}
      assigns(:split_errors).size.should == 1
      assigns(:splits).should be_nil
    end
  end
end
