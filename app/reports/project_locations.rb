require 'app/reports/base'
require 'app/charts/activities'
require 'active_support/core_ext/float'
require 'app/charts/project_locations'
require 'app/models/location_split'

module Reports
  class ProjectLocations < Reports::Base
    attr_reader :project

    def initialize(project)
      @project = project
    end

    def name
      project.name
    end

    def currency
      project.currency
    end

    def locations
      @locations ||= create_location_splits.sort
    end

    def collection
      locations
    end

    def total_spend
      project.total_spend
    end

    def total_budget
      project.total_budget
    end

    def percentage_change
      return 0 if total_spend == 0 || total_budget == 0
      change = ((total_budget.to_f / total_spend.to_f) * 100) - 100
      change.round_with_precision(1)
    end

    def expenditure_pie
      Charts::ProjectLocations::Spend.new(locations).google_pie
    end

    def budget_pie
      Charts::ProjectLocations::Budget.new(locations).google_pie
    end

    private

    # Report data is built as a collection of LocationSplit objects
    # which is easier than dealing with hashes or individual
    # CodingBudgetDistrict / CodingSpendDistrict objects
    def create_location_splits
      mapped_data = map_data(projects_locations)
      mapped_data.inject([]){ |splits, e|  splits << LocationSplit.new(e[0], e[1][:spend], e[1][:budget])}
    end

    def projects_locations
      (retrieve_codings(@project.activities, :budget) +
       retrieve_codings(@project.activities, :spend)).flatten
    end

    def retrieve_codings(activities, method)
      activities.map { |a| a.send("coding_#{method}_district") }
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

    def method_from_class(klass_string)
      klass_string.match("Spend") ? :spend : :budget
    end
  end
end
