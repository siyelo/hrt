require 'app/charts/projects'
require 'active_support/core_ext/float'

module Reports
  class Organization
    attr_reader :response

    def initialize(response)
      @response = response
    end

    def name
      @response.name
    end

    def currency
      @response.currency
    end

    def projects_and_other_costs
      (@response.projects + @response.other_costs).sort
    end

    def total_spend
      @response.total_spend
    end

    def total_budget
      @response.total_budget
    end

    def percentage_change
      return 0 if total_spend == 0 || total_budget == 0
      change = ((total_budget.to_f / total_spend.to_f) * 100) - 100
      change.round_with_precision(1)
    end

    def expenditure_pie
      Charts::Projects::Spend.new(projects_and_other_costs).google_pie
    end

    def budget_pie
      Charts::Projects::Budget.new(projects_and_other_costs).google_pie
    end
  end
end
