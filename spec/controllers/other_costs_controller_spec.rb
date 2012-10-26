require 'spec_helper'

describe OtherCostsController do
  describe "Redirects to budget or spend depending on datarequest" do
    before :each do
      @data_request  = FactoryGirl.create(:data_request)
      @organization  = FactoryGirl.create(:organization)
      @user          = FactoryGirl.create(:reporter, organization: @organization)
      @data_response = @organization.latest_response
      @project       = FactoryGirl.create(:project, data_response: @data_response)
      @other_cost    = FactoryGirl.create(:other_cost, project: @project, data_response: @data_response)
      login @user
    end

    it "redirects to the edit other cost page when Save is clicked" do
      put :update, other_cost: {description: "some description"}, id: @other_cost.id,
        commit: 'Save', response_id: @data_response.id
      response.should redirect_to(edit_other_cost_path(@other_cost.id))
    end

    it "redirects to the location classifications page when Save & Add Locations is clicked" do
      @data_request.save
      put :update, other_cost: { name: "prewprew" }, id: @other_cost.id,
        commit: 'Save & Add Locations >', response_id: @data_response.id
      response.should redirect_to edit_other_cost_path(@project.other_costs.first, mode: 'locations')
    end

    it "redirects to the purpose classifications page when Save & Add Purposes is clicked" do
      @data_request.save
      put :update, other_cost: { name: "prewprew" }, id: @other_cost.id,
        commit: 'Save & Add Purposes >', response_id: @data_response.id
      response.should redirect_to edit_other_cost_path(@project.other_costs.first, mode: 'purposes')
    end
    it "redirects to the input classifications page when Save & Add Inputs is clicked" do
      @data_request.save
      put :update, other_cost: { name: "prewprew" }, id: @other_cost.id,
        commit: 'Save & Add Inputs >', response_id: @data_response.id
      response.should redirect_to edit_other_cost_path(@project.other_costs.first, mode: 'inputs')
    end
    it "redirects to the output classifications page when Save & Add Targets is clicked" do
      @data_request.save
      put :update, other_cost: { name: "prewprew" }, id: @other_cost.id,
        commit: 'Save & Add Outputs, Targets & Beneficiaries >', response_id: @data_response.id
      response.should redirect_to edit_other_cost_path(@project.other_costs.first, mode: 'outputs')
    end

    it "correctly updates when an othercost doesn't have a project" do
      @other_cost    = FactoryGirl.create(:other_cost, project: nil,
                                data_response: @data_response)
      put :update, other_cost: {description: "some description"}, id: @other_cost.id,
                                   commit: 'Save', response_id: @data_response.id
      flash[:notice].should == "Indirect Cost was successfully updated."
      response.should redirect_to(edit_other_cost_path(@other_cost.id))
    end

    it "correctly updates when an othercost doesn't have a project or a spend" do
      @other_cost    = FactoryGirl.create(:other_cost, project: nil,
                                data_response: @data_response)
      put :update, other_cost: {description: "some description"}, id: @other_cost.id,
                                   commit: 'Save', response_id: @data_response.id
      flash[:notice].should == "Indirect Cost was successfully updated."
      response.should redirect_to(edit_other_cost_path(@other_cost.id))
    end
  end

  describe "Permissions" do
    context "Activity Manager" do
      before :each do
        @data_request = FactoryGirl.create :data_request
        @organization = FactoryGirl.create :organization
        @user = FactoryGirl.create :activity_manager, organization: @organization
        @data_response = @organization.latest_response
        @project = FactoryGirl.create(:project, data_response: @data_response)
        @other_cost = FactoryGirl.create :other_cost, project: @project,
          data_response: @data_response
        login @user
      end

      it "disallows an activity manager to create an other_cost" do
        request.env["HTTP_REFERER"] = new_other_cost_path(response_id: @data_response.id)

        controller.should_not_receive(:create)
        post :create, response_id: @data_response.id
        flash[:error].should == "You do not have permission to edit this resource"
        response.should redirect_to(new_other_cost_path(response_id: @data_response.id))
      end

      it "disallows an activity manager to update an other_cost" do
        request.env["HTTP_REFERER"] = edit_other_cost_path(@other_cost,
                                       response_id: @other_cost.response.id )

        controller.should_not_receive(:update)
        put :update, id: @other_cost.id, response_id: @data_response.id
        flash[:error].should == "You do not have permission to edit this resource"
        response.should redirect_to(edit_other_cost_path(@other_cost, response_id: @data_response.id))
      end


      it "disallows an activity manager to destroy an other_cost" do
        request.env["HTTP_REFERER"] = edit_other_cost_url(@other_cost, response_id: @data_response.id)
        controller.should_not_receive(:destroy)
        delete :destroy, id: @other_cost.id, response_id: @data_response.id
        flash[:error].should == "You do not have permission to edit this resource"
        response.should redirect_to(edit_other_cost_path(@other_cost, response_id: @data_response.id))
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
        @other_cost = FactoryGirl.create :other_cost, project: @project,
          data_response: @data_response
      end

      it "allows the editing of the organization the reporter is in" do
        login @user

        request.env["HTTP_REFERER"] = edit_other_cost_url(@data_response, @other_cost)
        session[:return_to] = edit_other_cost_path(@other_cost)
        put :update, id: @other_cost.id, response_id: @data_response.id,
          other_cost: {description: "thedesc", project_id: @project.id}

        flash[:error].should_not == "You do not have permission to edit this other_cost"
        flash[:notice].should == "Indirect Cost was successfully updated."
        response.should redirect_to(edit_other_cost_url(@other_cost))
      end

      it "disallows the editing of organization the reporter is not in" do
        request.env['HTTP_REFERER'] = edit_other_cost_path(@other_cost,
                                        response_id: @other_cost.response.id)
        @organization2 = FactoryGirl.create :organization
        @user = FactoryGirl.create :user, roles: ['reporter', 'activity_manager'],
          organization: @organization2
        @user.organizations << @organization
        login @user

        controller.should_not_receive(:update)
        put :update, id: @other_cost.id, response_id: @other_cost.data_response.id
        flash[:error].should == "You do not have permission to edit this resource"
        response.should redirect_to(edit_other_cost_path(@other_cost, response_id: @data_response.id))
      end
    end

    context "who are sysadmins and activity managers" do
      before :each do
        @data_request = FactoryGirl.create :data_request
        @organization = FactoryGirl.create :organization
        @user = FactoryGirl.create :user, roles: ['admin', 'activity_manager'],
          organization: @organization
        @data_response = @organization.latest_response
        @project = FactoryGirl.create(:project, data_response: @data_response)
        @other_cost = FactoryGirl.create :other_cost, project: @project,
          data_response: @data_response
        login @user
      end

      it "allows creation of an other_cost" do
        @other_cost.delete
        session[:return_to] = new_other_cost_url(@data_response)
        post :create, response_id: @data_response.id,
          other_cost: {project_id: '-1', name: "new other_cost", description: "description",
            "implementer_splits_attributes"=>
              {"0"=> {"spend"=>"2",
                "organization_mask"=>"#{@organization.id}", "budget"=>"4"}}}

        flash[:error].should_not == "You do not have permission to edit this other_cost"
        flash[:notice].should match("Indirect Cost was successfully created.")
      end

      it "allows them to edit the other_cost" do
        session[:return_to] = edit_other_cost_url(@data_response, @other_cost)
        put :update, id: @other_cost.id, response_id: @data_response.id,
          other_cost: {description: "thedesc", project_id: @project.id}

        flash[:error].should_not == "You do not have permission to edit this other_cost"
        flash[:notice].should == "Indirect Cost was successfully updated."
        response.should redirect_to(edit_other_cost_url(@other_cost))
        @other_cost.reload.description.should == "thedesc"
      end
    end
  end
end

