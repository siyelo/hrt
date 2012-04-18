# concerned with error checking and validation of Response data
#
class DataResponse < ActiveRecord::Base
  module ErrorChecker
    extend ActiveSupport::Memoizable

    def empty?
      activities.empty? && projects.empty?
    end

    def load_validation_errors
      errors.add_to_base("Projects are not yet entered.") unless projects_entered?
      errors.add_to_base("Activites are not yet entered.") unless projects_have_activities?
      errors.add_to_base("Activites are not yet classified.") unless activities_coded?
      errors.add_to_base("Projects have invalid funding sources.") unless projects_have_valid_funding_sources?
      if projects_have_other_costs? && !other_costs_coded?
        errors.add_to_base("Other Costs are not yet classified.")
      end
      unless implementer_splits_entered_and_valid?
        errors.add_to_base("Activities are missing implementers or implementer
        splits are invalid.")
      end
    end

    def basics_done?
      projects_entered? &&
        projects_have_activities? &&
        projects_have_valid_funding_sources? &&
        implementer_splits_entered_and_valid? &&
        activities_coded? &&
        (projects_have_other_costs? ? other_costs_coded? : true)
    end

    def basics_done_to_h
      {:projects_entered => projects_entered?,
        :projects_have_activities => projects_have_activities?,
        :projects_have_valid_funding_sources => projects_have_valid_funding_sources?,
        :implementer_splits_entered => implementer_splits_entered_and_valid?,
        :activities_coded  => activities_coded?,
        :other_costs_coded => (projects_have_other_costs? ? other_costs_coded? : true)}
    end

    def ready_to_submit?
      basics_done?
    end

    def projects_entered?
      !projects.empty?
    end
    memoize :projects_entered?

    def projects_have_valid_funding_sources?
      projects_with_invalid_funding_sources.empty?
    end
    memoize :projects_have_valid_funding_sources?

    def projects_with_invalid_funding_sources
      projects.select do |p|
        p.in_flows.empty? || !p.funding_sources_have_organizations_and_amounts?
      end
    end

    def activities_entered?
      !normal_activities.empty?
    end
    memoize :activities_entered?

    def projects_have_activities?
      activities.find(:first,
                      :select => 'COUNT(DISTINCT(activities.project_id)) as total',
                      :conditions => {:type => nil, :project_id => projects}
                     ).total.to_i == projects.length
    end
    memoize :projects_have_activities?

    def other_costs_entered?
      !other_costs.empty?
    end
    memoize :other_costs_entered?

    def projects_have_other_costs?
      other_costs = activities.find(:first,
                                    :select => 'COUNT(DISTINCT(activities.project_id)) as total',
                                    :conditions => {:type => 'OtherCost', :project_id => projects}
                                   ).total.to_i
                                   other_costs > 0 && other_costs == projects.length
    end
    memoize :projects_have_other_costs?

    def implementer_splits_entered_and_valid?
      activities_without_implementer_splits.empty? && invalid_implementer_splits.empty?
    end

    def invalid_implementer_splits
      invalid = []
      activities.each do |activity|
        activity.implementer_splits.select{ |is| !is.valid? }.each do |split|
          invalid << split
        end
      end
      return invalid
    end

    def activities_without_implementer_splits
      activities.select { |a| a.implementer_splits.empty? }
    end

    def uncoded_activities
      reject_uncoded(normal_activities)
    end

    def coded_activities
      select_coded(normal_activities)
    end

    def uncoded_other_costs
      reject_uncoded_locations(other_costs)
    end

    def coded_other_costs
      select_coded(other_costs)
    end

    def activities_coded?
      activities_entered? && uncoded_activities.empty?
    end
    memoize :activities_coded?

    def other_costs_coded?
      other_costs_entered? && uncoded_other_costs.empty?
    end
    memoize :other_costs_coded?


    def submittable?
      started? || rejected?
    end

    private

    def reject_uncoded(activities)
      activities.select{ |a| !a.budget_classified? || !a.spend_classified? }
    end

    def reject_uncoded_locations(other_costs)
      other_costs.select{ |oc| !oc.coding_budget_district_valid? ||
        !oc.coding_spend_district_valid? }
    end

    # Find all complete Activities
    def select_coded(activities)
      activities.select{ |a| a.classified? }
    end

    # Find all complete Ocosts
    def select_coded_ocosts(other_costs)
      other_costs.select{ |a| a.classified? }
    end

    def select_failing(collection, validation_method, amount_method)
      collection.select{|e| !self.send(validation_method, e, amount_method)}
    end
  end
end
