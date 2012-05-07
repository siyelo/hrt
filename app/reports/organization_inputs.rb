require 'app/reports/base'
require 'app/charts/inputs'
require 'app/models/input_split'

module Reports
  class OrganizationInputs < Reports::Base
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
      mapped_data = map_data(budget_and_spend_codings)
      mapped_data.inject([]){ |splits, e|  splits << InputSplit.new(e[0], e[1][:spend], e[1][:budget])}
    end

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

    # All CodingBudgetDistrict and CodingSpendDistrict objects for given response
    def budget_and_spend_codings
      (retrieve_codings(@response.activities, :budget) +
       retrieve_codings(@response.activities, :spend)).flatten
    end

    def retrieve_codings(activities, method)
      activities.map { |a| a.send("leaf_#{method}_inputs") }
    end

    def method_from_class(klass_string)
      case klass_string
      when "CodingSpendCostCategorization" then :spend
      when "CodingBudgetCostCategorization" then :budget
      end
    end
  end
end
