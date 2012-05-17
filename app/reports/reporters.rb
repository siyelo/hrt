require 'app/reports/base'
require 'app/charts/base'
require 'app/reports/row'
require 'lib/currency_number_helper'

module Reports
  class Reporters < Reports::Base
    include CurrencyNumberHelper

    def initialize(request)
      @resource = request
    end

    def currency
      "USD"
    end

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

    private

    def create_rows
      mapped_data.map do |split|
        Reports::Row.new( split[0],
                          split[1]["spend"].round(2),
                          split[1]["budget"].round(2) )
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
          universal_currency_converter(e.tot_spend.to_f, currency, 'USD')
        result[name]["budget"] +=
          universal_currency_converter(e.tot_budget.to_f, currency, 'USD')
        result
      end
    end

    def rows
      @rows = ImplementerSplit.find(:all,
               :joins => "INNER JOIN activities ON
                   activities.id = implementer_splits.activity_id
                   LEFT OUTER JOIN projects ON projects.id = activities.project_id
                   INNER JOIN data_responses ON
                   activities.data_response_id = data_responses.id
                   INNER JOIN data_requests ON
                   data_responses.data_request_id = data_requests.id
                   INNER JOIN organizations ON
                   data_responses.organization_id = organizations.id",
               :select => "organizations.name AS org_name,
                    COALESCE(projects.currency, organizations.currency) AS amount_currency,
                    SUM(implementer_splits.spend) AS tot_spend,
                    SUM(implementer_splits.budget) AS tot_budget",
               :conditions => "data_responses.data_request_id = #{@resource.id}",
               :group => "organizations.name, amount_currency" )
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

