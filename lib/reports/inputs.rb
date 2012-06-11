require_relative 'classification_base'

module Reports
  class Inputs < Reports::ClassificationBase
    # activity: activity object
    # type:  :spend or :budget
    def splits(activity, type)
      case type
      when :spend
        activity.input_spend_splits.roots
      when :budget
        activity.input_budget_splits.roots
      end
    end
  end
end

