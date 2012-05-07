require 'app/reports/organization_inputs'
require 'app/charts/inputs'
require 'app/models/input_split'

module Reports
  class ProjectInputs < Reports::OrganizationInputs
    attr_reader :project

    def initialize(project)
      @project = project
    end

    def name
      @project.name
    end

    def currency
      @project.currency
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

    # All leaf_spend_inputs and leaf_budget_inputs objects for given project
    def codings
      (retrieve_codings(@project.activities, :budget) +
       retrieve_codings(@project.activities, :spend)).flatten
    end
  end
end
