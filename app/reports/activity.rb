require 'app/charts/implementer_splits'
require 'active_support/core_ext/float'

module Reports
  class Activity
    attr_reader :activity

    def initialize(activity)
      @activity = activity
    end

    def name
      activity.name
    end

    def currency
      activity.currency
    end

    def implementer_splits
      activity.implementer_splits.sorted.find(:all, :include => :organization)
    end

    def total_spend
      activity.total_spend
    end

    def total_budget
      activity.total_budget
    end

    def percentage_change
      return 0 if total_spend == 0 || total_budget == 0
      change = ((total_budget.to_f / total_spend.to_f) * 100) - 100
      change.round_with_precision(1)
    end

    def expenditure_pie
      Charts::ImplementerSplits::Spend.new(implementer_splits).google_pie
    end

    def budget_pie
      Charts::ImplementerSplits::Budget.new(implementer_splits).google_pie
    end
  end
end
