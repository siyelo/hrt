require 'app/reports/base'
require 'app/reports/row'
require 'app/charts/base'
require 'lib/currency_number_helper'

module Reports
  class TopBase < Reports::Base
    include CurrencyNumberHelper

    def currency
      "USD"
    end

    ###
    # We have to use report::Rows here because funding flows dont respond
    # to total spend or budget or name
    def collection
      @collection ||= create_rows.sort{ |x,y| y.total_spend <=> x.total_spend }
    end

    def total_spend
      @total_spend ||= collection.inject(0) do |sum, e|
        sum + (e.total_spend || 0)
      end
    end

    def total_budget
      @total_budget ||= collection.inject(0) do |sum, e|
        sum + (e.total_budget || 0)
      end
    end

    def expenditure_chart
      Charts::Spend.new(top_spenders).google_column
    end

    def budget_chart
      Charts::Budget.new(top_budgeters).google_column
    end

    def show_totals
      false
    end

    def max_percentage
      return 0 if collection.blank?
      max_spend = (top_spenders[0].total_spend / total_spend) * 100
      max_budget = (top_budgeters[0].total_budget / total_budget) * 100
      max_spend > max_budget ? max_spend : max_budget
    end

    private
    ###
    # organizations report in differnt currencies
    # doing this ensures that there is no discrepencies
    def create_rows
      rows = []
      mapped_data.each_with_index do |md, index|
        rows << Reports::Row.new( md[0],
                                 md[1]["spend"].round(2),
                                 md[1]["budget"].round(2))
      end

      rows
    end

    ###
    # In the case that there are 2 of of the same organizations
    # because the query can't disregard organizations that report in
    # several currencies, this mapped_data merges thos organizations
    def mapped_data
      rows.inject({}) do |result, e|
        name = e.org_name
        currency = e.amount_currency
        result[name] ||= Hash.new(0)
        result[name]["spend"] +=
          universal_currency_converter(e.spend.to_f, currency, 'USD')
        result[name]["budget"] +=
          universal_currency_converter(e.budget.to_f, currency, 'USD')
        result
      end
    end

    def top_spenders
      collection
    end

    def top_budgeters
      @top_budgeters ||= collection.sort do |x, y|
        (y.total_budget || 0) <=> (x.total_budget || 0)
      end
    end
  end
end
