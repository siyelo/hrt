require 'app/charts/activities'
require 'active_support/core_ext/float'

module Reports
  class Project
    attr_reader :project

    def initialize(project)
      @project = project
    end

    def name
      project.name
    end

    def currency
      project.currency
    end

    def activities_and_other_costs
      project.activities.sorted
    end

    def total_spend
      project.total_spend
    end

    def total_budget
      project.total_budget
    end

    def percentage_change
      return 0 if total_spend == 0 || total_budget == 0
      change = ((total_budget.to_f / total_spend.to_f) * 100) - 100
      change.round_with_precision(1)
    end

    def expenditure_pie
      Charts::Activities::Spend.new(activities_and_other_costs).google_pie
    end

    def budget_pie
      Charts::Activities::Budget.new(activities_and_other_costs).google_pie
    end
  end
end
