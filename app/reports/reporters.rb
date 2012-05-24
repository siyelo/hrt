require 'app/reports/top_base'

module Reports
  class Reporters < TopBase
    def expenditure_chart
      Charts::Spend.new(top_spenders).google_column
    end

    def budget_chart
      Charts::Budget.new(top_budgeters).google_column
    end

    private
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
                    SUM(implementer_splits.spend) AS spend,
                    SUM(implementer_splits.budget) AS budget",
               :conditions => "data_responses.data_request_id = #{@resource.id}",
               :group => "organizations.name, amount_currency" )
    end
  end
end

