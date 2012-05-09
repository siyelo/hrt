class Dashboard::Reporter
  attr_accessor :reporter, :current_response, :params

  def initialize(reporter, current_response, params)
    @reporter         = reporter
    @current_response = current_response
    @params           = params
  end

  def template
    'reporter'
  end

  def comments
    @comments ||= Comment.paginate_for_responses([current_response], params[:page])
  end

  def documents
    @documents ||= Document.visible_to_reporters.latest_first.limited
  end
end
