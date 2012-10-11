# concerned with merging orgs
#
class Organization < ActiveRecord::Base
  def self.merge_organizations!(target, duplicate)
    duplicate.responses.each do |response|
      target_response = target.responses.find(:first,
        conditions: ["data_request_id = ?", response.data_request_id])
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

    duplicate.move_funder_references!(target)
    duplicate.move_implementer_references!(target)
    target.users << duplicate.users
    Organization.reset_counters(target.id,:users)
    target.reload
    # reload other organization so that it does not
    # remove the previously assigned data_responses
    duplicate.reload.destroy
  end

  module Merger
    def move_funder_references!(target_org)
      self.out_flows.each do |referencing_flow|
        referencing_flow.from = target_org
        referencing_flow.save(validate: false)
      end
    end

    # Merge helper
    def move_implementer_references!(target_org)
      self.implementer_splits.each do |referencing_split|
        referencing_split.organization = target_org
        referencing_split.save(validate: false)
      end
    end

  end
end
