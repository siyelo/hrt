require_relative 'top_base'

module Reports
  class Reporters < TopBase
    attr_accessor :resource, :include_double_count

    def initialize(resource, include_double_count = false)
      @resource = resource
      @include_double_count = include_double_count
    end

    private
    def rows
      splits = ImplementerSplit.select("organizations.name AS org_name,
         COALESCE(projects.currency, organizations.currency) AS amount_currency,
         SUM(implementer_splits.spend) AS spend,
         SUM(implementer_splits.budget) AS budget").
       joins("INNER JOIN activities ON
         activities.id = implementer_splits.activity_id
         LEFT OUTER JOIN projects ON projects.id = activities.project_id
         INNER JOIN data_responses ON
         activities.data_response_id = data_responses.id
         INNER JOIN data_requests ON
         data_responses.data_request_id = data_requests.id
         INNER JOIN organizations ON
         data_responses.organization_id = organizations.id").
       group('organizations.name, amount_currency')
      if @include_double_count
        splits = splits.where("data_responses.data_request_id = #{@resource.id}")
      else
        splits = splits.where(["data_responses.data_request_id = ?  AND
                              (implementer_splits.double_count = ?
                               OR implementer_splits.double_count IS NULL)",
                             @resource.id, false])
      end

      @rows = splits.all
    end
  end
end

