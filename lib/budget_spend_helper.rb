# This module is included in Activity, Project and FundingFlow models
require 'currency_number_helper'

module BudgetSpendHelper
  include CurrencyNumberHelper

  # the sum of all implementer split amounts
  # we dont apply a currency conversion because currency is assumed
  # to be uniform in the including module
  def total_spend
    implementer_splits.inject(0){ |sum, is| sum + (is.spend || 0) }
  end

  def total_budget
    implementer_splits.inject(0){ |sum, is| sum + (is.budget || 0) }
  end

  def converted_spend
    universal_currency_converter(total_spend, currency, response.currency)
  end

  def converted_budget
    universal_currency_converter(total_budget, currency, response.currency)
  end

  def smart_sum(collection, method)
    s = collection.reject do |e|
      e.nil? or e.send(method).nil? or e.marked_for_destruction?
    end.sum{ |e| e.send(method) }
    s || 0
  end
end
