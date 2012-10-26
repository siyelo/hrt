class OrganizationMerger
  attr_accessor :target, :duplicate, :target_id, :duplicate_id, :error

  def initialize(target_id, duplicate_id)
    @target_id = target_id
    @duplicate_id = duplicate_id
    find_organizations
  end

  def merge
    return false unless ready_for_merge?
    merge_organizations!
  end

  private
  def find_organizations
    if target_id && duplicate_id
      @target = Organization.find_by_id target_id
      @duplicate = Organization.find_by_id duplicate_id
    end
  end

  def ready_for_merge?
    unless target && duplicate
      @error = "Duplicate or target organizations not selected."
      return false
    end

    if target == duplicate
      @error = "Same organizations for duplicate and target selected."
      return false
    end

    if target.responses.blank? && duplicate.responses.present?
      @error = "An organization with responses cannot be merged into an organization without responses.  Try swap the duplicate and target organizations"
      return false
    end

     true
  end

  def merge_organizations!
    duplicate.responses.each do |response|
      target_response = target.responses.find(:first,
        :conditions => ["data_request_id = ?", response.data_request_id])
      target_response.state = DataResponse::States.
        merged_response_state(response.state, target_response.state)
      target_response.save(validate: false)

      target_response.projects << response.projects
      ### move Funder references of Duplicate to Target
      target_response.projects.each do |project|
        project.in_flows.each do |in_flow|
          if in_flow.from == duplicate
            in_flow.from = target
            in_flow.save(validate: false)
          end
        end
      end
      target_response.activities << response.activities
    end

    move_funder_references!(duplicate, target)
    move_implementer_references!(duplicate, target)
    target.users << duplicate.users
    Organization.reset_counters(target.id,:users)
    target.reload
    # reload other organization so that it does not
    # remove the previously assigned data_responses
    duplicate.reload.destroy
  end

  def move_funder_references!(organization, target_org)
    organization.out_flows.each do |referencing_flow|
      referencing_flow.from = target_org
      referencing_flow.save(validate: false)
    end
  end

  def move_implementer_references!(organization, target_org)
    organization.implementer_splits.each do |referencing_split|
      referencing_split.organization = target_org
      referencing_split.save(validate: false)
    end
  end
end
