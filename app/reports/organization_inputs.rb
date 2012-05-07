require 'app/reports/base'
require 'app/charts/inputs'
require 'app/models/input_split'

module Reports
  class OrganizationInputs < Reports::Base
    attr_reader :response

    def initialize(response)
      @response = response
    end

    def inputs
      @inputs ||= create_input_splits.sort
    end

    def collection
      inputs
    end

    def total_spend
      inputs.inject(0){ |sum, e| sum + ( e.total_spend || 0 ) }
    end

    def total_budget
      inputs.inject(0){ |sum, e| sum + ( e.total_budget || 0 ) }
    end

    def expenditure_pie
      Charts::Inputs::Spend.new(inputs).google_pie
    end

    def budget_pie
      Charts::Inputs::Budget.new(inputs).google_pie
    end

    private

    # Report data is built as a collection of LocationSplit objects
    # which is easier than dealing with hashes or individual
    # CodingBudgetDistrict / CodingSpendDistrict objects
    def create_input_splits
      mapped_data = map_data(codings)
      mapped_data.inject([]){ |splits, e|  splits << InputSplit.new(e[0], e[1][:spend], e[1][:budget])}
    end

    # All CodingBudgetDistrict and CodingSpendDistrict objects for given response
    def codings
      (retrieve_codings(@response.activities, :budget) +
       retrieve_codings(@response.activities, :spend)).flatten
    end

    def retrieve_codings(activities, method)
      activities.map { |a| a.send("leaf_#{method}_inputs") }
    end
  end
end
