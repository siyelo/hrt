class Reports::Detailed::ResponseOverview < Reports::Detailed::DynamicQuery
  attr_accessor :builder, :response

  def initialize(response, amount_type, filetype)
    @deepest_nesting = Code.deepest_nesting
    @amount_type = amount_type
    @response = response
    @implementer_splits = ImplementerSplit.find :all,
      joins: { activity: :data_response },
      order: "implementer_splits.id ASC",
      conditions: ['data_responses.id = ?', response.id],
      include: [
        { activity: [
          :targets,
          { "leaf_#{@amount_type}_purposes".to_sym => :code },
          { "leaf_#{@amount_type}_inputs".to_sym => :code },
          { "location_#{@amount_type}_splits".to_sym => :code },
          { project: { in_flows: :from } },
          { data_response: :organization },
          :implementer_splits, #eager load for activity.total_*
        ]},
        { organization: :data_responses } ]
    @builder = FileBuilder.new(filetype)
    @show_double_count = false
  end
end
