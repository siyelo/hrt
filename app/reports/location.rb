require 'app/reports/base'
require 'app/charts/locations'
require 'app/models/location_split'

module Reports
  class Location < Reports::Base
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

    def locations
      @locations ||= create_location_splits.sort
    end

    def collection
      locations
    end

    def total_spend
      locations.inject(0){ |sum, e| sum + e.total_spend }
    end

    def total_budget
      locations.inject(0){ |sum, e| sum + e.total_budget }
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
      mapped_data = map_data(budget_and_spend_codings)
      mapped_data.inject([]){ |splits, e|  splits << LocationSplit.new(e[0], e[1][:spend], e[1][:budget])}
    end

    # Combines collection of CodingBudgetDistrict and CodingSpendDistrict objects
    # into a single hash, keyed by Location (Code) name
    # E.g.
    #   { "Location1" => {:spend => 10, :budget => 10} }
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
      activities.map { |a| a.send("coding_#{method}_district") }
    end

    def method_from_class(klass_string)
      case klass_string
      when "CodingSpendDistrict" then :spend
      when "CodingBudgetDistrict" then :budget
      end
    end
  end
end
