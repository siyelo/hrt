require 'active_support/core_ext/float'
require_relative '../currency_view_number_helper'
require_relative '../currency_number_helper'

module Reports
  class Base
    include CurrencyViewNumberHelper
    include CurrencyNumberHelper
    include Rails.application.routes.url_helpers
    include ChartColours
    include ReportExporter
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
      change = 'N/A' if total_spend == 0 && total_budget > 0
      change = 0 if total_spend == 0 && total_budget == 0
      return change if change

      change = ((total_budget.to_f - total_spend.to_f) / total_spend.to_f) * 100
      change.round(1)
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

    def budget_value_method(element)
      element.total_budget
    end

    def spend_value_method(element)
      element.total_spend
    end

    def mark_duplicates(collection)
      non_duplicates = {}
      collection.each do |element|
        unless non_duplicates.include? element.name
          duplicates = collection.select{ |e| e.name == element.name }
          duplicates.each_with_index do |duplicate, index|
            name = index == 0 ? duplicate.name : "#{duplicate.name} #{index + 1}"
            non_duplicates[name] = Reports::Row.new(name,
                                                    spend_value_method(duplicate),
                                                    budget_value_method(duplicate),
                                                    resource_link(duplicate))
          end
        end
      end

      non_duplicates.values.sort
    end

    private
    ###
    # Determines whether it is a budget or spend
    def method_from_class(klass_string)
      klass_string.match("Spend") ? :spend : :budget
    end

    def top_budgeters
      @top_budgeters ||= collection.
        sort { |x, y| (y.total_budget || 0) <=> (x.total_budget || 0) }
    end

    def top_spenders
      @top_spenders ||= collection.
        sort { |x, y| (y.total_spend || 0) <=> (x.total_spend || 0) }
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
