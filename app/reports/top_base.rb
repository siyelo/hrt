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

    def expenditure_pie
      Charts::Spend.new(top_spenders).google_pie
    end

    def budget_pie
      Charts::Budget.new(top_budgeters).google_pie
    end

    def show_totals
      false
    end

    private
    ###
    # organizations report in differnt currencies
    # doing this ensures that there is no discrepencies
    def create_rows
      mapped_data.map do |md|
        Reports::Row.new( md[0],
                          md[1]["spend"].round(2),
                          md[1]["budget"].round(2) )
      end
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

    ####
    # The top 10 spenders
    def top_spenders
      collection
    end

    ####
    # The top 10 budgeters
    def top_budgeters
      collection.sort{ |x, y| y.total_budget <=> x.total_budget }
    end

  end
end
