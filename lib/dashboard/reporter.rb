class Dashboard::Reporter
  attr_accessor :reporter, :current_response

  def initialize(reporter, current_response)
    @reporter         = reporter
    @current_response = current_response
    @report           = Reports::Organization.new(current_response)
  end

  def template
    'reporter'
  end

  def comments
    @comments ||= Comment.published.recent_comments([current_response])
  end

  def documents
    @documents ||= Document.visible_to_reporters.latest_first.limited
  end
end
