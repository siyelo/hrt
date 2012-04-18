# concerned with the aggregation of projects and
# non-project other costs for a response
#
class DataResponse
  module Totaller
    def total_budget(to_currency = self.currency)
      sum_total(projects, :total_budget, to_currency) +
        non_project_costs(:total_budget, to_currency)
    end

    def total_spend(to_currency = self.currency)
      sum_total(projects, :total_spend, to_currency) +
        non_project_costs(:total_spend, to_currency)
    end

    def non_project_costs(method, to_currency = self.currency)
      sum_total(other_costs.without_a_project, method, to_currency)
    end

    private

    # Sums up the total_<field> amounts for the entities in the
    # given collection
    # e.g.
    #   sum_total projects, :total_spend
    #   sum_total other_costs, :total_budget, "RWF"
    def sum_total(collection, method, to_currency)
      collection.inject(0) do |sum, p|
        sum + (p.send(method) || 0) * currency_rate(p.currency, to_currency)
      end
    end
  end
end
