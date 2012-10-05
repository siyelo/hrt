class Reports::Detailed::ResponseOverview < Reports::Detailed::DynamicQuery
  include Rails.application.routes.url_helpers
  attr_accessor :builder, :response, :amount_type

  def initialize(response, amount_type, filetype)
    @deepest_nesting = Purpose.with_version(response.request.purposes_version).deepest_nesting
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

  def generate_report_for_download(user)
    generate_report
    Notifier.report_download_notification(user,
      download_overview_response_url(response, type: amount_type)).deliver
  end
  handle_asynchronously :generate_report_for_download

  def generate_report
    data do |content, filetype, mimetype|
      folder = "#{Rails.root}/tmp/"
      file_name = "#{response.id}_#{amount_type}.#{filetype}"
      type = amount_type == 'budget' ? 'budget' : 'expenditure'
      FileZipper.zip_content(folder, file_name, content) do |zip_file_path|
        response.send("#{type}_overview=", File.new(zip_file_path, 'r'))
        response.save
      end
    end
  end
end
