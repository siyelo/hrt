def basic_setup_response
  basic_setup_response_for_controller
  @request = @data_request
  @response = @data_response
end

#controller specs don't like you setting @request, @response
def basic_setup_response_for_controller
  request      = FactoryGirl.create :data_request
  @organization = FactoryGirl.create :organization
  @user = FactoryGirl.create :user, organization: @organization
  @data_request = request
  @data_response     = @organization.latest_response
end

def basic_setup_project
  basic_setup_project_for_controller
  @request = @data_request
  @response = @data_response
end

def basic_setup_project_for_controller
  basic_setup_response_for_controller
  @other_org = FactoryGirl.create(:organization)
  @project = Project.new(data_response: @data_response,
                         budget_type: "on",
                         name: "non_Factory_project_name_#{rand(100_000_000)}",
                         description: "proj descr",
                         start_date: "2010-01-01",
                         end_date: "2011-01-01",
                         currency: "USD",
                         in_flows_attributes: [organization_id_from: @other_org.id,
                           budget: 10, spend: 20])
  @project.save!
end

def basic_setup_activity
  @user         = FactoryGirl.create(:user)
  @organization = @user.organization
  @request      = FactoryGirl.create :data_request
  @response     = @organization.latest_response
  @project      = FactoryGirl.create(:project, data_response: @response)
  @activity     = FactoryGirl.create(:activity, data_response: @response, project: @project)
end

def basic_setup_other_cost
  @user         = FactoryGirl.create(:user)
  @organization = @user.organization
  @request      = FactoryGirl.create :data_request
  @response     = @organization.latest_response
  @project      = FactoryGirl.create(:project, data_response: @response)
  @other_cost   = FactoryGirl.create(:other_cost, data_response: @response, project: @project)
end

def basic_setup_implementer_split
  basic_setup_implementer_split_for_controller
  @request = @data_request
  @response = @data_response
end

def basic_setup_implementer_split_for_controller
  @user         = FactoryGirl.create(:user)
  @organization = @user.organization
  @data_request = FactoryGirl.create :data_request
  @data_response = @organization.latest_response
  @project      = FactoryGirl.create(:project, data_response: @data_response)
  @activity     = FactoryGirl.create(:activity, data_response: @data_response, project: @project)
  @split = FactoryGirl.create(:implementer_split, activity: @activity,
                   organization: @organization)
  @activity.save #recalculate implementer split total on activity
end

def basic_setup_funding_flow
  @donor        = FactoryGirl.create(:organization)
  @user         = FactoryGirl.create :user
  @organization = @user.organization
  @request      = FactoryGirl.create :data_request
  @response     = @organization.latest_response
  @project      = FactoryGirl.create(:project, data_response: @response)
  @funding_flow = FactoryGirl.create(:funding_flow, project: @project,
                          from: @donor)
end

def self_funded(proj, budget = 50, spend = 50)
  proj_funded_by(proj, proj.data_response.organization, budget, spend)
end

def proj_funded_by(proj, funder, budget = 50, spend = 50)
  FactoryGirl.create(:funding_flow, from: funder, project: proj,
          budget: budget, spend: spend)
  proj.reload
  proj
end
