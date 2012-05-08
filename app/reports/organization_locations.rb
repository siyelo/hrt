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
      locations_with_unclassified
    end

    def expenditure_pie
      Charts::Locations::Spend.new(collection).google_pie
    end

    def budget_pie
      Charts::Locations::Budget.new(collection).google_pie
    end

    def total_spend
      @total_spend ||= response.total_spend.to_f
    end

    def total_budget
      @total_budget ||= response.total_budget.to_f
    end

    def locations_budget
      locations.inject(0){ |sum, e| sum + ( e.total_budget || 0 ) }
    end

    def locations_spend
      locations.inject(0){ |sum, e| sum + ( e.total_spend || 0 ) }
    end

    private

    ###
    # This adds a location split equal to the unclassified amount
    # this allows it to be seen in the pie chart
    def locations_with_unclassified
      if totals_equals_locations?
        locations
      else
        locations << LocationSplit.new("Not Classified",
                                       remaining_spend, remaining_budget)
      end
    end

    def totals_equals_locations?
      total_budget == locations_budget && total_spend == locations_spend
    end

    # Report data is built as a collection of LocationSplit objects
    # which is easier than dealing with hashes or individual
    # CodingBudgetDistrict / CodingSpendDistrict objects
    def create_location_splits
      mapped_data = map_data(codings)
      mapped_data.inject([]) do |splits, e|
        splits << LocationSplit.new(e[0], e[1][:spend], e[1][:budget])
      end
    end

    # All CodingBudgetDistrict and CodingSpendDistrict objects for given response
    def codings
      (retrieve_codings(@response.activities, :budget) +
       retrieve_codings(@response.activities, :spend)).flatten
    end

    def retrieve_codings(activities, method)
      activities.map { |a| a.send("coding_#{method}_district") }
    end

    def remaining_spend
      total_spend - locations_spend
    end

    def remaining_budget
      total_budget - locations_budget
    end
  end
end
