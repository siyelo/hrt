require 'app/reports/organization_inputs'
require 'app/charts/inputs'
require 'app/models/input_split'

module Reports
  class ActivityInputs < Reports::OrganizationInputs
    attr_reader :activity

    def initialize(activity)
      @activity = activity
    end

    def name
      activity.name
    end

    def currency
      activity.data_response.currency
    end

    private

    # Report data is built as a collection of LocationSplit objects
    # which is easier than dealing with hashes or individual
    # CodingBudgetDistrict / CodingSpendDistrict objects
    def create_input_splits
      mapped_data = map_data(codings)
      mapped_data.inject([]) do |splits, e|
        splits << InputSplit.new(e[0], e[1][:spend], e[1][:budget])
      end
    end

    # All leaf_spend_inputs and leaf_budget_inputs objects for given activity
    def codings
      (retrieve_codings([activity], :budget) +
       retrieve_codings([activity], :spend)).flatten
    end
  end
end
