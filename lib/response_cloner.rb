class ResponseCloner
  attr_accessor :previous_request, :new_request

  def initialize(previous_request, new_request)
    @previous_request = previous_request
    @new_request = new_request
  end

  def deep_clone!
    previous_request.data_responses.each do |previous_response|
      new_response = new_request.data_responses.new
      new_response.organization_id = previous_response.organization.id
      new_response.projects = clone_projects(previous_response, new_response)
      new_response.previous_id = previous_response.id
      new_response.save(false)
      new_response.reload
      new_response.other_costs += clone_non_project_other_costs(previous_response, new_response)
      reset_response_state!(new_response)
    end
  end

  private
  def clone_projects(response, new_response)
    response.projects.map do |previous_project|
      project = previous_project.clone
      project.previous = previous_project
      project.data_response_id = nil
      %w[data_response_id budget_type].each do |assoc|
        project.send("#{assoc}=", nil)
      end
      project.in_flows = clone_in_flows(previous_project)
      project.activities = clone_activities(previous_project.activities, new_response)
      project.data_response = new_response
      project
    end
  end

  def clone_in_flows(project)
    project.in_flows.map do |in_flow|
      in_flow.project_id = nil
      in_flow.previous = in_flow
      in_flow.spend = 0
      in_flow.budget = 0
      in_flow.clone
    end
  end

  def clone_activities(activities, new_response)
    activities.map do |old_activity|
      activity = old_activity.clone
      activity.previous = old_activity
      %w[project_id approved am_approved data_response_id am_approved_date].each do |assoc|
        activity.send("#{assoc}=", nil)
      end
      activity.data_response = new_response
      activity.implementer_splits = clone_implementer_splits(old_activity)
      activity.beneficiaries = old_activity.beneficiaries
      activity.targets = clone_targets(old_activity)
      activity.outputs = clone_outputs(old_activity)
      activity
    end
  end

  def clone_non_project_other_costs(previous_response, new_response)
    ocosts = previous_response.other_costs.without_project
    clone_activities(ocosts, new_response)
  end

  def clone_implementer_splits(activity)
    activity.implementer_splits.map do |old_split|
      split = old_split.clone
      split.previous = old_split
      %w[activity_id double_count].each do |assoc|
        split.send("#{assoc}=", nil)
      end
      split.spend = 0
      split.budget = 0
      split
    end
  end

  def clone_targets(activity)
    activity.targets.map do |old_target|
      target = old_target.clone
      target.activity_id = nil
      target
    end
  end

  def clone_outputs(activity)
    activity.outputs.map do |old_output|
      output = old_output.clone
      output.activity_id = nil
      output
    end
  end

  def reset_response_state!(new_response)
    new_response.state = "unstarted"
    new_response.save(false)
  end
end
