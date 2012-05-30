require 'active_support/core_ext/float'
require 'lib/currency_view_number_helper'

module Reports
  class Base
    include CurrencyViewNumberHelper
    include ActionController::UrlWriter
    include ChartColours
    attr_accessor :resource

    def initialize(resource)
      @resource = resource
    end

    def name
      @resource.name
    end

    def currency
      @resource.currency
    end

    def total_spend
      @total_spend ||= @resource.total_spend
    end

    def total_budget
      @total_budget ||= @resource.total_budget
    end

    def format(value)
      n2c(value, "", ",")
    end

    def resource_link(name)
      nil
    end

    def expenditure_chart
      Charts::Spend.new(collection).google_pie
    end

    def budget_chart
      Charts::Budget.new(collection).google_pie
    end

    def chart_links
      {}.to_json
    end

    def expenditure_colours
      colours = {}
      top_spenders[0..14].each_with_index do |ts, index|
        colours[index] = { :color => get_colour(ts.name) }
      end

      colours.to_json
    end

    def budget_colours
      colours = {}
      top_budgeters[0..14].each_with_index do |ts, index|
        colours[index] = { :color => get_colour(ts.name) }
      end

      colours.to_json
    end

    def percentage_change
      change = -100  if total_spend >  0 && total_budget == 0
      change = 'N/A' if total_spend == 0 && total_budget > 0
      change = 0     if total_spend == 0 && total_budget == 0

      return change if change

      change = ((total_budget.to_f / total_spend.to_f) * 100) - 100
      change.round_with_precision(1)
    end

    def unit
      currency
    end

    def show_totals
      true
    end

    def max_percentage
      100
    end

    private

    # Combines collection of LocationBudgetSplit and LocationSpendSplit objects
    # into a single hash, keyed by Location (Code) name
    # E.g.
    #   { "Input1" => {:spend => 10, :budget => 10} }
    #
    def map_data(collection)
      collection.inject({}) do |result,e|
        result[e.name] ||= {}
        result[e.name][method_from_class(e.class.to_s)] ||= 0
        result[e.name][method_from_class(e.class.to_s)] += e.cached_amount || 0
        result
      end
    end

    ###
    # Determines whether it is a budget or spend
    def method_from_class(klass_string)
      klass_string.match("Spend") ? :spend : :budget
    end

    def top_budgeters
      @top_budgeters ||= collection.sort do |x, y|
        (y.total_budget || 0) <=> (x.total_budget || 0)
      end
    end

    def top_spenders
      @top_spenders ||= collection.sort do |x, y|
        (y.total_spend || 0) <=> (x.total_spend || 0)
      end
    end

    def get_colour(name)
      @colours ||= assign_colours
      @colours[name]
    end

    def assign_colours
      top_budget = top_budgeters[0..14].map{ |row| row.name }
      top_spend = top_spenders[0..14].map{ |row| row.name }
      top_all = (top_spend + top_budget).uniq!
      colours = {}
      top_all.each_with_index do |name, index|
        colours[name] = AVAILABLE_COLOURS[index]
      end

      colours
    end
  end
end
