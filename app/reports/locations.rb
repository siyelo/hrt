require 'app/reports/classification_base'

module Reports
  class Locations < Reports::ClassificationBase
    # activity: activity object
    # type:  :spend or :budget
    def splits(activity, type)
      case type
      when :spend
        activity.coding_spend_district
      when :budget
        activity.coding_budget_district
      end
    end
  end
end
