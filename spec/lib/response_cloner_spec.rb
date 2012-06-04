require 'spec_helper'

describe ResponseCloner do
  before :each do
    @current_request = Factory :data_request
    @organization    = Factory :organization
    user             = Factory :user, :organization => @organization
    @current_response = @organization.latest_response
    other_org        = Factory :organization
    @current_project  = Project.new(
                          :data_response => @current_response,
                          :budget_type => "ON",
                          :name => "Current_Project",
                          :description => "proj descr",
                          :start_date => "2010-01-01",
                          :end_date => "2011-01-01",
                          :currency => "USD",
                          :in_flows_attributes => [:organization_id_from => other_org.id,
                                                   :budget => 10, :spend => 20])
    @current_project.save!
    current_oc_without_project = Factory(:other_cost, :project => nil,
                                         :data_response => @current_response)
    @current_activity   = Factory(:activity,
                                 :data_response => @current_response,
                                 :project => @current_project)
    current_other_cost = Factory(:other_cost,
                                 :data_response => @current_response,
                                 :project => @current_project)
    @current_activity.beneficiaries = [Factory :beneficiary]
    @current_activity.targets       = [Factory :target]
    @current_activity.outputs       = [Factory :output]
    @current_split    = Factory :implementer_split,
                                :activity => @current_activity,
                                :organization => @organization,
                                :budget => 100,
                                :spend => 200
    @current_activity.save #recalculate implementer split total on activity
  end

  it "should clone a single response" do
    @new_request = Factory :data_request #clones previous response

    new_response = @organization.data_responses.with_request(@new_request).first
    project = new_response.projects.first
    activity = project.activities.first

    #it sets the correct response state
    new_response.unstarted?.should be_true

    #it sets up previous relationship
    new_response.previous.should == @current_response
    project.previous.should == @current_project
    activity.previous.should == @current_activity
    project.in_flows.first.previous.should ==
      @current_project.in_flows.first
    activity.implementer_splits.first.previous.should ==
      @current_split

    #it clones and zeroes out in_flows
    project.in_flows.count.should == 1
    project.in_flows_total_spend.should == 0
    project.in_flows_total_budget.should == 0

    #it clones & zeroes out projects
    project.budget_type.should == "on"
    project.total_spend.should == 0
    project.total_budget.should == 0

    #clones activities & other costs
    project.activities.count.should == 2
    new_response.activities.count.should == 3
    new_response.other_costs.without_project.count.should == 1

    #it clones and zeroes out implementers
    activity.implementer_splits.count.should == 1
    activity.implementer_splits.first.spend.should == 0
    activity.implementer_splits.first.budget.should == 0

    #it clones outputs, targets & beneficiaries
    activity.beneficiaries.count.should == 1
    activity.targets.count.should == 1
    activity.outputs.count.should == 1
    Beneficiary.count.should == 1 #sanity - doesn't create new beneficiaries

    #it does not change existing data
    @current_project.reload
    @current_project.total_budget.should == 100
    @current_project.total_spend.should == 200
    @current_project.in_flows_total_budget.to_i.should == 10
    @current_project.in_flows_total_spend.to_i.should == 20

    Activity.last.data_response_id.should_not be_nil
  end

  it "should clone all projects and activities in a request" do
    organization2     = Factory :organization
    user              = Factory :user, :organization => organization2
    current_response2 = organization2.latest_response
    current_project2  = Project.new(
                          :data_response => current_response2,
                          :budget_type => "ON",
                          :name => "Current_Project",
                          :description => "proj descr",
                          :start_date => "2010-01-01",
                          :end_date => "2011-01-01",
                          :currency => "USD",
                          :in_flows_attributes => [:organization_id_from => @organization.id,
                                                   :budget => 10, :spend => 20])
    current_project2.save!
    current_activity2 = Factory(:activity,
                                :data_response => current_response2,
                                :project => current_project2)
    current_activity2.beneficiaries = [Factory :beneficiary]
    current_activity2.targets       = [Factory :target]
    current_activity2.outputs       = [Factory :output]
    current_split2    = Factory :implementer_split,
                                :activity => current_activity2,
                                :organization => organization2
    current_activity2.save #recalculate implementer split total on activity
    @new_request      = Factory :data_request

    new_response2     = organization2.data_responses.with_request(@new_request).first

    project2 = new_response2.projects.first
    activity2 = new_response2.projects.first.activities.first

    new_response2.previous.should == current_response2
    new_response2.projects.count.should == 1
    project2.in_flows.count.should      == 1
    project2.activities.count.should    == 1

    project2.total_spend.should           == 0
    project2.total_budget.should          == 0
    project2.in_flows_total_spend.should  == 0
    project2.in_flows_total_budget.should == 0

    activity2.implementer_splits.count.should == 1
    activity2.beneficiaries.count.should      == 1
    activity2.targets.count.should            == 1
    activity2.outputs.count.should            == 1
  end

end
