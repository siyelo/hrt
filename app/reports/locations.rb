require 'app/reports/classification_base'

module Reports
  class Locations < Reports::ClassificationBase
    # activity: activity object
    # type:  :spend or :budget
    def splits(activity, type)
      case type
      when :spend
        activity.location_spend_splits
      when :budget
        activity.location_budget_splits
      end
    end
  end
end
