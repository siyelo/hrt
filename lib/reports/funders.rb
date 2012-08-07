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
      funders = FundingFlow.select("organizations.name AS org_name,
         projects.id AS project_id, projects.currency AS amount_currency,
         spend AS spend, budget AS budget").
       joins([:from, { :project => :data_response } ]).
       group("organizations.name, projects.id, amount_currency, spend, budget")
      if @include_double_count
        funders = funders.where("data_responses.data_request_id = #{request.id}")
      else
        funders = funders.where(["data_responses.data_request_id = ?  AND
                              (funding_flows.double_count = ?
                               OR funding_flows.double_count IS NULL)",
                             request.id, false])
      end

      @rows ||= funders.all
    end
  end
end
