require 'app/reports/classification_base'

module Reports
  class Inputs < Reports::ClassificationBase
    # activity: activity object
    # type:  :spend or :budget
    def splits(activity, type)
      case type
      when :spend
        activity.coding_spend_cost_categorization.roots
      when :budget
        activity.coding_budget_cost_categorization.roots
      end
    end
  end
end

