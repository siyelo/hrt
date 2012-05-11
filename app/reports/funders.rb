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
      @collection ||= create_rows.sort
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

    private

    ###
    # organizations report in differnt currencies
    # doing this ensures that there is no discrepencies
    def create_rows
      funders.map do |ff|
        org_currency = ff.organization.currency
        Reports::Row.new( ff.organization.name,
          universal_currency_converter(ff.spend, org_currency, currency),
          universal_currency_converter(ff.budget, org_currency, currency) )
      end
    end

    def funders
       @funders ||= FundingFlow.find(:all,
         :joins => [:from, { :project => :data_response } ],
         :order => 'funding_flows.id ASC',
         :conditions => ['data_responses.data_request_id = ?', @resource.id],
         :order => 'organization_id_from ASC')
    end
  end
end
