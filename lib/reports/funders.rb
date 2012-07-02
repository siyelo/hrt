module Reports
  class Funders < TopBase
    include ImplementerSplitRatio

    attr_accessor :request, :include_double_count

    def initialize(request, include_double_count = false)
      @request = request
      @include_double_count = include_double_count
      super(request)
    end

    private
    def rows
       @rows ||= FundingFlow.find(:all, :joins => [:from, { :project => :data_response } ],
                   :select => "organizations.name AS org_name,
                               projects.id AS project_id,
                               projects.currency AS amount_currency,
                               spend AS spend,
                               budget AS budget",
                   :conditions => ['data_responses.data_request_id = ?', request.id],
                   :group => "organizations.name, projects.id, amount_currency, spend, budget")
    end

    def mapped_data
      rows.inject({}) do |result, e|
        name = e.org_name
        currency = e.amount_currency
        result[name] ||= Hash.new(0)

        project_id = e.project_id.to_i
        spend_ratio = include_double_count ? 1.0 : ratios[project_id][:spend]
        budget_ratio = include_double_count ? 1.0 : ratios[project_id][:budget]

        result[name]["spend"] += spend_ratio * ucc(e.spend.to_f, currency, 'USD')
        result[name]["budget"] += budget_ratio * ucc(e.budget.to_f, currency, 'USD')
        result
      end
    end

    def ratios
      return @ratios if @ratios

      @ratios = {}
      rows.map(&:project_id).uniq.each do |project_id|
        @ratios[project_id.to_i] = Hash.new(1)
      end

      implementer_splits = ImplementerSplit.
        joins(:activity => [:project, :data_response]).
        select('activities.project_id, implementer_splits.double_count,
               SUM(implementer_splits.budget) AS budget,
               SUM(implementer_splits.spend) AS spend').
        where(['data_request_id = ? AND spend > 0', request.id]).
        group('activities.project_id, implementer_splits.double_count')

      grouped_implementer_splits = implementer_splits.group_by{|is| is.project_id}

      grouped_implementer_splits.each do |project_id, all_splits|
        nondouble_splits = all_splits.select{|is| !is.double_count }

        project_id = project_id.to_i
        @ratios[project_id] ||= Hash.new(1)
        @ratios[project_id][:budget] = budget_ratio(all_splits, nondouble_splits)
        @ratios[project_id][:spend] = spend_ratio(all_splits, nondouble_splits)
      end

      @ratios
    end
  end
end
