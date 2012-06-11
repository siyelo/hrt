class Reports::Detailed::FundingSource
  include Reports::Detailed::Helpers
  include CurrencyNumberHelper
  include CurrencyViewNumberHelper

  attr_accessor :builder

  def initialize(request, filetype)
   @in_flows = FundingFlow.find :all,
     :joins => { :project => :data_response },
     :order => 'funding_flows.id ASC',
     :conditions => ['data_responses.data_request_id = ? AND
                     data_responses.state = ?', request.id, 'accepted']
    @builder = FileBuilder.new(filetype)
  end

  def data(&block)
    build_rows
    builder.data(&block)
  end

  private
    def build_rows
      builder.add_row(build_header)
      @in_flows.each do |in_flow|
        build_in_flow_rows(in_flow)
      end
    end

    def build_header
      row = []

      row << 'Funding Source'
      row << "Organization"
      row << 'Project'
      row << 'On/Off Budget'
      row << 'Disbursement Received'
      row << 'Planned Disbursement'
      row
    end

    def build_in_flow_rows(in_flow)
      in_flow_currency = in_flow.project.currency
      row = []
      row << in_flow.from.try(:name)
      row << in_flow.organization.try(:name)
      row << in_flow.project.name
      row << project_budget_type(in_flow.project)
      row << universal_currency_converter(in_flow.spend, in_flow_currency, "USD")
      row << universal_currency_converter(in_flow.budget, in_flow_currency, "USD")
      builder.add_row(row)
    end
end
