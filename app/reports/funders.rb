require 'app/reports/base'
require 'app/charts/base'
require 'app/reports/row'
require 'lib/currency_number_helper'

module Reports
  class Funders < Reports::Base
    include CurrencyNumberHelper

    def initialize(request)
      @resource = request
    end

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


    private

    ###
    # organizations report in differnt currencies
    # doing this ensures that there is no discrepencies
    def create_rows
      mapped_data.map do |ff|
        Reports::Row.new( ff[0],
                          ff[1]["spend"].round(2),
                          ff[1]["budget"].round(2) )
      end
    end

    ###
    # In the case that there are 2 of of the same organizations
    # because the query can't disregard organizations that report in
    # several currencies, this mapped_data merges thos organizations
    def mapped_data
      funders.inject({}) do |result, e|
        name = e.organization.name
        currency = e.organization.currency
        result[name] ||= Hash.new(0)
        result[name]["spend"] +=
          universal_currency_converter(e.spend.to_f, currency, 'USD')
        result[name]["budget"] +=
          universal_currency_converter(e.budget.to_f, currency, 'USD')
        result
      end
    end

    def funders
       @funders ||= FundingFlow.find(:all,
         :joins => [:from, { :project => :data_response } ],
         :order => 'funding_flows.id ASC',
         :conditions => ['data_responses.data_request_id = ?', @resource.id],
         :order => 'organization_id_from ASC')
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
