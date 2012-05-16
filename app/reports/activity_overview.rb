class Reports::ActivityOverview
  include Reports::Helpers
  include CurrencyNumberHelper
  include CurrencyViewNumberHelper

  attr_accessor :builder

  def initialize(request, filetype)
    @implementer_splits = ImplementerSplit.find :all,
      :joins => { :activity => :data_response },
      :order => "implementer_splits.id ASC",
      :conditions => ['data_responses.data_request_id = ? AND
                       data_responses.state = ?', request.id, 'accepted'],
      :include => [{ :activity => [{ :project => { :in_flows => :from } },
                                  { :data_response => :organization } ]},
                                  { :organization => :data_responses }]
    @builder = FileBuilder.new(filetype)
  end

  def data(&block)
    build_rows
    builder.data(&block)
  end

  private
  def build_rows
    builder.add_row(build_header)
    @implementer_splits.each do |implementer_split|
      builder.add_row(build_row(implementer_split))
    end
  end

  def build_header
    row = []
    row << 'Organization'
    row << 'Project'
    row << 'On/Off Budget'
    row << 'Activity'
    row << 'Activity ID'
    row << 'Activity URL'
    row << 'Funding Source'
    row << 'Implementer'
    row << 'Implementer Type'
    row << 'Implementer Split ID'
    row << 'Expenditure ($)'
    row << 'Budget ($)'
    row << 'Possible Double-Count?'
    row << 'Actual Double-Count?'
    row
  end

  def build_row(implementer_split)
    activity = implementer_split.activity
    row = []
    row << activity.organization.name
    row << activity.project.try(:name) # other costs does not have a project
    row << project_budget_type(activity.project)
    row << activity.name
    row << activity.id
    row << activity_url(activity)
    row << project_in_flows(activity.project)
    row << implementer_split.organization.try(:name)
    row << implementer_split.organization.try(:implementer_type)
    row << implementer_split.id
    row << universal_currency_converter(implementer_split.spend, activity.currency, 'USD')
    row << universal_currency_converter(implementer_split.budget, activity.currency, 'USD')
    row << implementer_split.possible_double_count?
    # don't use double_count?, we need to display if the value is nil
    row << implementer_split.double_count
    row
  end
end
