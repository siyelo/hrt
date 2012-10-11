class Reports::Detailed::Targets
  include Reports::Detailed::Helpers
  include CurrencyNumberHelper
  include CurrencyViewNumberHelper

  attr_accessor :builder

  def initialize(request, amount_type, filetype)
    @is_budget          = is_budget?(amount_type)
    @amount_type        = amount_type
    @implementer_splits = ImplementerSplit.find :all,
      joins: { activity: :data_response },
      order: "implementer_splits.id ASC",
      conditions: ['data_responses.data_request_id = ? AND
                       data_responses.state = ?', request.id, 'accepted'],
      include: [{ activity: [{ project: { in_flows: :from } },
        { data_response: :organization }, :targets, :implementer_splits ]},
        { organization: :data_responses }]
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
      build_row(implementer_split)
    end
  end

  def build_header
    row = []
    amount_name = @amount_type.to_s.capitalize

    row << 'Organization'
    row << 'Project'
    row << 'Funding Source'
    row << 'Activity'
    row << 'Activity ID'
    row << 'Activity URL'
    row << "Total Activity #{amount_name} ($)"
    row << 'Implementer'
    row << 'Implementer Type'
    row << 'Activity Target'
    row << "Total Implementer #{amount_name} ($)"
    row << 'Possible Double-Count?'
    row << 'Actual Double-Count?'

    row
  end

  def build_row(implementer_split)
    activity = implementer_split.activity
    rate = currency_rate(activity.currency, 'USD')
    split_amount = 0

    if @is_budget
      activity_amount = activity.total_budget || 0
      split_amount    = implementer_split.budget || 0
    else
      activity_amount = activity.total_spend || 0
      split_amount    = implementer_split.spend || 0
    end

    base_row = []

    base_row << activity.organization.name
    base_row << activity.project.try(:name) # other costs does not have a project
    base_row << project_in_flows(activity.project)
    base_row << activity.name
    base_row << activity.id
    base_row << activity_url(activity)
    base_row << activity_amount * rate
    base_row << implementer_split.organization.try(:name)
    base_row << implementer_split.organization.try(:implementer_type)

    # fake target if none
    targets = activity.targets.presence || [Target.new(description: 'n/a')]
    targets.each do |target|
      row = base_row.dup
      amount_by_ratio = split_amount * (1.0 / targets.length)
      row << target.description
      row << amount_by_ratio * rate
      row << implementer_split.possible_double_count?
      # don't use double_count?, we need to display if the value is nil
      row << implementer_split.double_count
      builder.add_row(row)
    end
  end
end
