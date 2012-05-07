require 'active_support/core_ext/float'

module Reports
  class Base
    def name
      @response.name
    end

    def currency
      @response.currency
    end

    def percentage_change
      return 0 if total_spend == 0 || total_budget == 0
      change = ((total_budget.to_f / total_spend.to_f) * 100) - 100
      change.round_with_precision(1)
    end

    private

    # Combines collection of CodingBudgetDistrict and CodingSpendDistrict objects
    # into a single hash, keyed by Location (Code) name
    # E.g.
    #   { "Input1" => {:spend => 10, :budget => 10} }
    #
    def map_data(collection)
      collection.inject({}) do |result,e|
        result[e.name] ||= {}
        result[e.name][method_from_class(e.class.to_s)] ||= 0
        result[e.name][method_from_class(e.class.to_s)] += e.cached_amount.to_f
        result
      end
    end

    ###
    # Determines whether it is a budget or spend
    def method_from_class(klass_string)
      klass_string.match("Spend") ? :spend : :budget
    end
  end
end
