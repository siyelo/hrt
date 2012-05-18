module Reports
  class Funders < TopBase

    private

    def rows
       @rows ||= FundingFlow.find(:all,
                   :joins => [:from, { :project => :data_response } ],
                   :select => "funding_flows.id,
                               organizations.name AS org_name,
                               organizations.currency AS amount_currency,
                               spend AS spend,
                               budget AS budget",
                   :conditions => ['data_responses.data_request_id = ?', @resource.id],
                   :group => "funding_flows.id, organizations.name, amount_currency")
    end
  end
end
