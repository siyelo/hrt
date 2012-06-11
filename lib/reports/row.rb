# Represents the assignment of a Location to an activity
#
# (At time of writing is used as a pseudo-aggregate of LocationBudgetSplit & Spend equivalents
#
require 'action_view/helpers/number_helper'
require 'bigdecimal'

module Reports
  class Row
    include ActionView::Helpers::NumberHelper
    attr_reader :name, :total_spend, :total_budget
    def initialize(name, spend = 0, budget = 0)
      @name = name
      @total_spend = BigDecimal.new(spend.to_s)
      @total_budget = BigDecimal.new(budget.to_s)
    end

    def <=>(x)
      self.name <=> x.name
    end

    def ==(another_split)
      self.name == another_split.name &&
        self.total_spend == another_split.total_spend &&
        self.total_budget == another_split.total_budget
    end
  end
end
