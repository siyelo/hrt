require 'app/reports/base'
require 'app/charts/base'
require 'app/reports/row'

module Reports
  class Reporters < Reports::Base
    def initialize(request)
      @resource = request
    end

    def currency
      "USD"
    end

    ### uses reports::rows because it has to calculate total_spend and total_budget
    # every time during the sort because it's not a stored field
    def collection
      responses
    end

    def total_budget
      responses.inject(0) do |sum, e|
        sum + (e.total_budget || 0)
      end
    end

    def total_spend
      responses.inject(0) do |sum, e|
        sum + (e.total_spend || 0)
      end
    end

    private

    def responses
      @responses ||= @resource.data_responses.find(:all,
        :include => [ :organization,
          {:projects => {:activities => :implementer_splits} },
          {:other_costs => :implementer_splits} ],
        :order => 'organizations.name')
    end
  end
end

