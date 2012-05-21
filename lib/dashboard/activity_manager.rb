class Dashboard::ActivityManager
  attr_accessor :activity_manager, :current_response, :current_request, :params

  def initialize(activity_manager, current_response, current_request, params)
    @activity_manager = activity_manager
    @current_response = current_response
    @current_request  = current_request
    @params           = params
  end

  def template
    'activity_manager'
  end

  def approved_count
    Activity.with_organization.count(:all,
      :conditions =>  ["organization_id in (?) AND
                data_responses.data_request_id = ? AND
                am_approved = ?", organization_ids, current_request, true])
  end

  def all_count
    Activity.with_organization.count(:all,
      :conditions =>  ["organization_id in (?) AND
                        data_responses.data_request_id = ?",
                        organization_ids, current_request])
  end

  def pending_count
    all_count - approved_count
  end

  def organizations_count
    organizations.length
  end

  def recent_responses
    current_request.data_responses.find(:all,
      :conditions => ["state = ? AND organization_id in (?)",
                      'submitted', organization_ids],
      :order => 'updated_at DESC', :limit => 3)
  end

  def organizations
    @organizations ||= activity_manager.organizations
  end

  def comments
    @comments ||= Comment.paginate_for_responses(data_responses, params[:page])
  end

  def documents
    @documents = Document.visible_to_reporters.latest_first.limited
  end

  private
    def organization_ids
      @organization_ids ||= organizations.map{|o| o.id}
    end

    def data_responses
      return @data_responses if @data_responses

      @data_responses = organizations.map do |o|
        o.data_responses.select{|dr| dr.data_request_id == current_request.id }
      end.flatten
      @data_responses << current_response

      @data_responses
    end
end
