require 'app/reports/base'
require 'app/reports/row'
require 'app/charts/base'

module Reports
  class ClassificationBase < Reports::Base
    def collection
      @collection ||= rounded(rows_with_unclassified)
    end

    protected

    def rows_budget
      rows.inject(0){ |sum, e| sum + ( e.total_budget || 0 ) }
    end

    def rows_spend
      rows.inject(0){ |sum, e| sum + ( e.total_spend || 0 ) }
    end

    def rows
      @rows ||= create_rows.sort
    end

    ###
    # This adds an input split equal to the unclassified amount
    # this allows it to be seen in the pie chart
    def rows_with_unclassified
      if totals_equals_rows?
        rows
      else
        [rows, Reports::Row.new("Not Classified",
                                 remaining_spend, remaining_budget)].flatten
      end
    end

    def rounded(splits)
      splits.map do |s|
        Reports::Row.new(s.name, s.total_spend.round(2),
                       s.total_budget.round(2))
      end
    end

    def totals_equals_rows?
      total_budget == rows_budget && total_spend == rows_spend
    end

    # Report data is built as a collection of Row objects
    # which is easier than dealing with hashes or individual
    # CodingBudgetDistrict / CodingSpendDistrict objects
    def create_rows
      mapped_data = map_data(codings)
      mapped_data.inject([]) do |splits, e|
        splits << Reports::Row.new(e[0], e[1][:spend], e[1][:budget])
      end
    end

    # This works for organizations(responses) and projects
    def activities
      @resource.activities
    end

    # All CodingBudgetDistrict and CodingSpendDistrict objects for given resource
    # subclasses need to define implementation of
    # activities() and splits()
    def codings
      ( activities.map { |a| a.send(splits(:spend)) } +
        activities.map { |a| a.send(splits(:budget)) }).flatten
    end

    def retrieve_codings(activities, method)
      activities.map { |a| a.send("leaf_#{method}_inputs") }
    end

    def remaining_spend
      total_spend - rows_spend
    end

    def remaining_budget
      total_budget - rows_budget
    end
  end
end