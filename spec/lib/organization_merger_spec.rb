require 'spec_helper'

describe OrganizationMerger do
  context "#ready_for_merge?" do
    describe "returns false and sets the correct error" do
      it "checks that both organizations exist" do
        merger = OrganizationMerger.new("1", "1")
        merger.merge.should == false
        merger.error.should == "Duplicate or target organizations not selected."
      end

      it "doesn't allow the same organization to merge" do
        organization = FactoryGirl.create(:organization)
        merger = OrganizationMerger.new(organization.id, organization.id)
        merger.merge.should == false
        merger.error.should == "Same organizations for duplicate and target selected."
      end

      it "checks that the target responses are present if there are duplicate responses" do
        current_request = FactoryGirl.create :data_request
        target = FactoryGirl.create(:organization)
        duplicate = FactoryGirl.create(:organization)
        FactoryGirl.create(:user, organization: duplicate)
        duplicate.reload

        merger = OrganizationMerger.new(target.id, duplicate.id)
        merger.merge.should == false
        merger.error.should == "An organization with responses cannot be merged into an organization without responses.  Try swap the duplicate and target organizations"
      end
    end
  end

  describe "remove duplicate organization" do
    before :each do
      @organization       = FactoryGirl.create(:organization)
      FactoryGirl.create(:data_request, organization: @organization)
      @target_org         = FactoryGirl.create(:organization, name: "Target org")
      @duplicate_org      = FactoryGirl.create(:organization, name: "Duplicate org")
      @target_org_user    = FactoryGirl.create(:user, organization: @target_org)
      @duplicate_org_user = FactoryGirl.create(:user, organization: @duplicate_org)
      @target_response    = @target_org.reload.latest_response
      @duplicate_response = @duplicate_org.reload.latest_response
      FactoryGirl.create(:data_request, organization: @organization)
      @target_response2    = @target_org.latest_response
      @duplicate_response2 = @duplicate_org.latest_response
    end

    it "should use the lower of the two started response states" do
      @target_org.reload.responses.latest_first.first.accept!(@target_org_user)
      @duplicate_org.reload.responses.latest_first.first.start!(@duplicate_org_user)
      merger = OrganizationMerger.new(@target_org.id, @duplicate_org.id)
      merger.merge
      @target_org.responses.latest_first.first.state.should == 'started'
    end

    it "should use the duplicate response state if target is unstarted" do
      @target_org.reload.responses.latest_first.first.state = 'unstarted'
      @duplicate_org.reload.responses.latest_first.first.start!(@duplicate_org_user)
      merger = OrganizationMerger.new(@target_org.id, @duplicate_org.id)
      merger.merge
      @target_org.responses.latest_first.first.state.should == 'started'
    end

    it "should use the target response state if duplicate is unstarted" do
      @target_org.reload.responses.latest_first.first.submit!(@target_org_user)
      @duplicate_org.reload.responses.latest_first.first.state = 'unstarted'
      merger = OrganizationMerger.new(@target_org.id, @duplicate_org.id)
      merger.merge
      @target_org.responses.latest_first.first.state.should == 'submitted'
    end

    it "should move users" do
      merger = OrganizationMerger.new(@target_org.id, @duplicate_org.id)
      merger.merge
      @target_org.users.should == [@target_org_user, @duplicate_org_user]
      @target_org.reload.users.should == [@target_org_user, @duplicate_org_user]
      @target_org.users_count.should == @target_org.users.size
    end

    it "deletes duplicate after merge" do
      merger = OrganizationMerger.new(@target_org.id, @duplicate_org.id)
      merger.merge
      all_organizations = Organization.all
      all_organizations.should include(@target_org)
      all_organizations.should_not include(@duplicate_org)
    end

    it "moves projects from duplicate to target organization" do
      project1 = FactoryGirl.create(:project, data_response: @duplicate_response)
      project2 = FactoryGirl.create(:project, data_response: @duplicate_response2)

      merger = OrganizationMerger.new(@target_org.id, @duplicate_org.id)
      merger.merge
      all_organizations = Organization.all
      @target_response.projects.should include(project1)
      @target_response2.projects.should include(project2)
      all_organizations.should include(@target_org)
      all_organizations.should_not include(@duplicate_org)
    end

    it "copies also invalid data responses from duplicate to @target" do
      duplicate_data_response = @duplicate_org.latest_response
      merger = OrganizationMerger.new(@target_org.id, @duplicate_org.id)
      merger.merge
      @target_org.data_responses.count.should == 2 # not 2, since our before block created a valid DR
    end

    it "moves activities from duplicate to target organization" do
      project1 = FactoryGirl.create(:project, data_response: @duplicate_response)
      project2 = FactoryGirl.create(:project, data_response: @duplicate_response2)
      activity1 = FactoryGirl.create(:activity, data_response: @duplicate_response,
                          project: project1)
      activity2 = FactoryGirl.create(:activity, data_response: @duplicate_response2,
                          project: project2)

      merger = OrganizationMerger.new(@target_org.id, @duplicate_org.id)
      merger.merge
      @target_response.activities.should include(activity1)
      @target_response2.activities.should include(activity2)
      activity1.project.should == project1
      activity2.project.should == project2
    end

    it "should move other costs without a project" do
      oc = FactoryGirl.create(:other_cost_fully_coded, data_response: @duplicate_response)
      merger = OrganizationMerger.new(@target_org.id, @duplicate_org.id)
      merger.merge
      @target_response.other_costs.should include(oc)
      oc.reload
      oc.organization.should == @target_org
      oc.data_response.should == @target_response
    end

    context "when referenced" do
      before :each do
        organization  = FactoryGirl.create(:organization, name: "other org")
        user = FactoryGirl.create :user, organization: organization
        data_response = organization.latest_response
        @other_project = Project.new(data_response: data_response,
                                     name: "p1",
                                     currency: "USD",
                                     budget_type: "on",
                                     description: "proj descr",
                                     start_date: "2010-01-01",
                                     end_date: "2011-01-01",
                                     in_flows_attributes: [
                                       organization_id_from: @duplicate_org.id,
                                       budget: 10, spend: 20])
        @other_project.save!
        @other_activity = FactoryGirl.create(:activity, data_response: data_response,
                                  project: @other_project)
        split = FactoryGirl.create(:implementer_split, activity: @other_activity,
                        organization: @duplicate_org)
        @other_activity.reload.save #recalculates IS total of activity
      end

      it "should point funder references to new target org" do
        merger = OrganizationMerger.new(@target_org.id, @duplicate_org.id)
        merger.merge
        @other_project.reload.in_flows.first.from.should == @target_org
        @target_org.out_flows.should == [@other_project.in_flows.first]
      end

      it "should point implementer references to new target org" do
        @other_activity.implementer_splits.first.organization.should == @duplicate_org
        merger = OrganizationMerger.new(@target_org.id, @duplicate_org.id)
        merger.merge
        @other_activity.reload.implementer_splits.first.organization.should == @target_org
      end
    end
  end

end
