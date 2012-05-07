require 'app/charts/locations'
require 'app/models/location_split'

module Reports
  class ActivityLocation < Reports::OrganizationLocations
    attr_reader :activity

    def initialize(activity)
      @activity = activity
    end

    def name
      activity.name
    end

    def currency
      activity.currency
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

    # All CodingBudgetDistrict and CodingSpendDistrict objects for given activity
    def codings
      (retrieve_codings([activity], :budget) +
       retrieve_codings([activity], :spend)).flatten
    end
  end
end
