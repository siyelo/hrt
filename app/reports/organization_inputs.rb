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
      inputs_with_unclassified
    end

    def expenditure_pie
      Charts::Inputs::Spend.new(inputs).google_pie
    end

    def budget_pie
      Charts::Inputs::Budget.new(inputs).google_pie
    end

    def total_spend
      @total_send ||= response.total_spend.to_f
    end

    def total_budget
      @total_budget ||= response.total_budget.to_f
    end

    def inputs_budget
      inputs.inject(0){ |sum, e| sum + ( e.total_budget || 0 ) }
    end

    def inputs_spend
      inputs.inject(0){ |sum, e| sum + ( e.total_spend || 0 ) }
    end

    private

    ###
    # This adds an input split equal to the unclassified amount
    # this allows it to be seen in the pie chart
    def inputs_with_unclassified
      if totals_equals_inputs?
        inputs
      else
        inputs << InputSplit.new("Not Classified",
                                 remaining_spend, remaining_budget)
      end
    end

    def totals_equals_inputs?
      total_budget == inputs_budget && total_spend == inputs_spend
    end

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

    def remaining_spend
      total_spend - inputs_spend
    end

    def remaining_budget
      total_budget - inputs_budget
    end
  end
end
