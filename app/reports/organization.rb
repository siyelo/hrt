require 'app/reports/base'
require 'app/charts/projects'

module Reports
  class Organization < Reports::Base
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
      (@response.projects + @response.other_costs).
        sort{ |a, b| a.name.downcase <=> b.name.downcase }
    end

    def collection
      projects_and_other_costs
    end

    def total_spend
      @response.total_spend
    end

    def total_budget
      @response.total_budget
    end

    def expenditure_pie
      Charts::Projects::Spend.new(projects_and_other_costs).google_pie
    end

    def budget_pie
      Charts::Projects::Budget.new(projects_and_other_costs).google_pie
    end
  end
end
