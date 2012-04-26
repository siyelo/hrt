class DashboardController < ApplicationController
  COMMENT_LIMIT = 25

  ### Filters
  before_filter :require_user
  before_filter :load_comments

  ### Public Methods

  # Load the dashboard with any special conditions detected by user type
  def index
    setup_current_organization_response
    load_activity_manager if current_user.activity_manager? && !current_user.sysadmin?
    load_requests
    load_documents
  end

  protected
    # load Activity Manager-specific dashboard items
    def load_activity_manager
      @organizations = current_user.organizations
      organization_ids = @organizations.map{|o| o.id}
      @approved_activities = Activity.only_simple.with_organization.count(:all,
        :conditions =>  ["organization_id in (?) AND
                          data_responses.data_request_id = ? AND
                          am_approved = ?", organization_ids, current_request, true])
      @total_activities = Activity.only_simple.with_organization.count(:all,
        :conditions =>  ["organization_id in (?) AND
                          data_responses.data_request_id = ?", organization_ids, current_request])
      @recent_responses = current_request.data_responses.find(:all,
        :conditions => ["state = ? AND organization_id in (?)",
                        'submitted', organization_ids],
        :order => 'updated_at DESC', :limit => 3)
      @pending_activities = @total_activities - @approved_activities
    end


    # Comment loading for all types of users
    def load_comments
      if current_user.sysadmin?
        @comments = Comment.paginate :all,
                     :order => 'created_at DESC',
                     :include => [:user, :commentable],
                     :per_page => COMMENT_LIMIT, :page => params[:page]
      elsif current_user.activity_manager?
        dr_ids = current_user.organizations.map{|o| o.data_responses.map{|dr| dr.id }}.flatten
        dr_ids += current_user.organization.data_responses.map{|dr| dr.id }
        @comments  = Comment.on_all(dr_ids).
          paginate :per_page => COMMENT_LIMIT, :page => params[:page]
      else
        @comments = Comment.on_all(current_user.organization.data_responses.map{|r| r.id}).
          paginate :per_page => COMMENT_LIMIT, :page => params[:page]
      end
    end

    # Request loading for all types of users
    def load_requests
      @requests = DataRequest.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 5
    end

    def load_documents
      scope = current_user.sysadmin? ? Document : Document.visible_to_reporters
      @documents = scope.latest_first.limited
    end

    def setup_current_organization_response
      if current_request
        @response = current_user.organization.data_responses.
          find_by_data_request_id(current_request.id)
      end
    end
end
