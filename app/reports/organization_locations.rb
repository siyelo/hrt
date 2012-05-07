require 'app/reports/base'
require 'app/charts/locations'
require 'app/models/location_split'

module Reports
  class OrganizationLocations < Reports::Base
    attr_reader :response

    def initialize(response)
      @response = response
    end

    def locations
      @locations ||= create_location_splits.sort
    end

    def collection
      locations
    end

    def total_spend
      locations.inject(0){ |sum, e| sum + ( e.total_spend || 0 ) }
    end

    def total_budget
      locations.inject(0){ |sum, e| sum + ( e.total_budget || 0 ) }
    end

    def expenditure_pie
      Charts::Locations::Spend.new(locations).google_pie
    end

    def budget_pie
      Charts::Locations::Budget.new(locations).google_pie
    end

    private

    # Report data is built as a collection of LocationSplit objects
    # which is easier than dealing with hashes or individual
    # CodingBudgetDistrict / CodingSpendDistrict objects
    def create_location_splits
      mapped_data = map_data(codings)
      mapped_data.inject([]){ |splits, e|  splits << LocationSplit.new(e[0], e[1][:spend], e[1][:budget])}
    end

    # All CodingBudgetDistrict and CodingSpendDistrict objects for given response
    def codings
      (retrieve_codings(@response.activities, :budget) +
       retrieve_codings(@response.activities, :spend)).flatten
    end

    def retrieve_codings(activities, method)
      activities.map { |a| a.send("coding_#{method}_district") }
    end
  end
end
