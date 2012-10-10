require_relative 'base'
require_relative 'row'
require_relative '../charts/base'

module Reports
  class ClassificationBase < Reports::Base
    def collection
      @collection ||= mark_duplicates(rounded(rows_with_unclassified))
    end

    def totals_equals_rows?
      (remaining_spend + remaining_budget).round(2) == 0.00
    end

    protected

    def rows_budget
      rows.inject(0){ |sum, e| sum + (e.total_budget || 0) }
    end

    def rows_spend
      rows.inject(0){ |sum, e| sum + (e.total_spend || 0) }
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

    # Report data is built as a collection of Row objects
    # which is easier than dealing with hashes or individual
    # LocationBudgetSplit / LocationSpendSplit objects
    def create_rows
      mapped_data = map_data(codings)
      mapped_data.inject([]) do |splits, e|
        splits << Reports::Row.new(e[0], e[1][:spend], e[1][:budget])
      end
    end

    # Combines collection of LocationBudgetSplit and LocationSpendSplit objects
    # into a single hash, keyed by Location (Code) name
    # E.g.
    #   { "Input1" => {:spend => 10, :budget => 10} }
    #
    def map_data(collection)
      collection.inject({}) do |result,e|
        result[e.name] ||= {}
        result[e.name][method_from_class(e.spend)] ||= 0
        value = universal_currency_converter((e.cached_amount || 0), e.currency, @resource.currency)
        result[e.name][method_from_class(e.spend)] += value
        result
      end
    end

    # This works for organizations(responses) and projects
    def activities
      @resource.activities
    end

    # All LocationBudgetSplit and LocationSpendSplit objects for given resource
    # subclasses need to define implementation of
    # activities() and splits()
    def codings
      ( activities.map { |a| splits(a, :spend) } +
        activities.map { |a| splits(a, :budget) }).flatten.select do |c|
          c.cached_amount && c.cached_amount > 0.0
        end
    end

    def remaining_spend
      total_spend - rows_spend
    end

    def remaining_budget
      total_budget - rows_budget
    end
  end
end
