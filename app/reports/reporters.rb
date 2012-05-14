require 'app/reports/base'
require 'app/charts/base'
require 'app/reports/row'
require 'lib/currency_number_helper'

module Reports
  class Reporters < Reports::Base
    include CurrencyNumberHelper

    ### Constants
    NUMBER_OF_VALUES_IN_CHARTS = 10

    def initialize(request)
      @resource = request
    end

    def currency
      "USD"
    end

    def collection
      @collection ||= create_rows
    end

    def total_spend
      collection.inject(0) do |sum, e|
        sum + (e.total_spend || 0)
      end
    end

    def total_budget
      collection.inject(0) do |sum, e|
        sum + (e.total_budget || 0)
      end
    end

    def expenditure_pie
      Charts::Spend.new(top_spenders).google_pie
    end

    def budget_pie
      Charts::Budget.new(top_budgeters).google_pie
    end

    private

    def create_rows
      rows.map do |split|
        if split.tot_spend.to_f > 0 && split.tot_budget.to_f > 0
          org_currency = split.currency
          Reports::Row.new(split.org_name,
            universal_currency_converter(split.tot_spend.to_f, org_currency, "USD"),
            universal_currency_converter(split.tot_budget.to_f, org_currency, "USD"))
        end
      end.compact
    end

    def top_spenders
      collection.sort{ |x, y| y.total_spend <=> x.total_spend }.
        first(NUMBER_OF_VALUES_IN_CHARTS)
    end

    def top_budgeters
      collection.sort{ |x, y| y.total_budget <=> x.total_budget }.
        first(NUMBER_OF_VALUES_IN_CHARTS)
    end

    def rows
      @rows = ImplementerSplit.find(:all,
               :joins => "INNER JOIN activities ON
                   activities.id = implementer_splits.activity_id
                   INNER JOIN data_responses ON
                   activities.data_response_id = data_responses.id
                   INNER JOIN data_requests ON
                   data_responses.data_request_id = data_requests.id
                   INNER JOIN organizations ON
                   data_responses.organization_id = organizations.id",
               :select => "organizations.name AS org_name,
                    implementer_splits.currency AS currency,
                    SUM(implementer_splits.spend) AS tot_spend,
                    SUM(implementer_splits.budget) AS tot_budget",
               :conditions => "data_responses.data_request_id = #{@resource.id}",
               :group => "organizations.name, implementer_splits.currency" )
    end
  end
end

