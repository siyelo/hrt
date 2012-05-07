require 'app/reports/organization_locations'
require 'app/charts/locations'
require 'app/models/location_split'

module Reports
  class ProjectLocations < Reports::OrganizationLocations
    attr_reader :project

    def initialize(project)
      @project = project
    end

    def currency
      project.currency
    end

    def name
      project.name
    end

    private

    # Report data is built as a collection of LocationSplit objects
    # which is easier than dealing with hashes or individual
    # CodingBudgetDistrict / CodingSpendDistrict objects
    def create_location_splits
      mapped_data = map_data(codings)
      mapped_data.inject([]) do |splits, e|
        splits << LocationSplit.new(e[0], e[1][:spend], e[1][:budget])
      end
    end

    def codings
      (retrieve_codings(@project.activities, :budget) +
       retrieve_codings(@project.activities, :spend)).flatten
    end
  end
end
