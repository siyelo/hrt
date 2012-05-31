module Reports
  class Funders < TopBase
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
