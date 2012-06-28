class Dashboard::Sysadmin
  include ActionView::Helpers::NumberHelper

  attr_accessor :sysadmin, :current_request

  def initialize(sysadmin, current_request)
    @sysadmin        = sysadmin
    @current_request = current_request
  end

  def template
    'sysadmin'
  end

  def submitted_responses
    @submitted_responses ||= current_request.data_responses.submitted.
      find(:all, :include => :organization,
           :order => 'updated_at DESC', :limit => 4)
  end

  def accepted_count
    @accepted_count ||= current_request.data_responses.accepted.count
  end

  def started_count
    @started_count ||= current_request.data_responses.started.count
  end

  def not_yet_started_count
    @not_yet_started_count ||= current_request.data_responses.unstarted.count
  end

  def accepted_percent
    calculate_percent(accepted_count)
  end

  def started_percent
    calculate_percent(started_count)
  end

  def not_yet_started_percent
    calculate_percent(not_yet_started_count)
  end

  def pending_approval
    current_request.data_responses.submitted.count
  end

  def comments
    @comments ||= Comment.published.recent_comments(current_request.data_responses)
  end

  def documents
    @documents ||= Document.latest_first.limited
  end

  def reporting_organizations
    Organization.reporting.count
  end

  def total_users
    User.count
  end

  private

  def calculate_percent(number)
    number_to_percentage(number * 100 / all_count.to_f, :precision => 0)
  end

  def all_count
    @all_count ||= current_request.data_responses.count
  end
end
