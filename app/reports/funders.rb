module Reports
  class Funders < TopBase
    def expenditure_chart
      Charts::Spend.new(top_spenders).google_column
    end

    def budget_chart
      Charts::Budget.new(top_budgeters).google_column
    end

    private
    def rows
       @rows ||= FundingFlow.find(:all, :joins => [:from, { :project => :data_response } ],
                   :select => "organizations.name AS org_name,
                               projects.currency AS amount_currency,
                               spend AS spend,
                               budget AS budget",
                   :conditions => ['data_responses.data_request_id = ?', @resource.id],
                   :group => "organizations.name, amount_currency, spend, budget")
    end
  end
end
