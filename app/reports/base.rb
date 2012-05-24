require 'active_support/core_ext/float'
require 'lib/currency_view_number_helper'

module Reports
  class Base
    include CurrencyViewNumberHelper
    include ActionController::UrlWriter
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

    def expenditure_pie
      Charts::Spend.new(collection).google_pie
    end

    def budget_pie
      Charts::Budget.new(collection).google_pie
    end

    def percentage_change
      return 0 if total_spend == 0 || total_budget == 0
      change = ((total_budget.to_f / total_spend.to_f) * 100) - 100
      change.round_with_precision(1)
    end

    def unit
      currency
    end

    def show_totals
      true
    end

    private

    # Combines collection of CodingBudgetDistrict and CodingSpendDistrict objects
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
  end
end
