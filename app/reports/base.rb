require 'active_support/core_ext/float'

module Reports
  class Base
    def percentage_change
      return 0 if total_spend == 0 || total_budget == 0
      change = ((total_budget.to_f / total_spend.to_f) * 100) - 100
      change.round_with_precision(1)
    end
  end
end
