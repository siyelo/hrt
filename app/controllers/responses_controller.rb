class ResponsesController < BaseController
  include FileSender

  before_filter :require_user
  before_filter :require_admin, :only => [:restart]
  before_filter :require_activity_manager, :only => [:reject, :accept] #includes sysadmin
  before_filter :load_response_from_id

  def review
    ActiveRecord::Associations::Preloader.new(@response,
      [{:projects => :normal_activities}]).run
    @projects = @response.projects
  end

  def submit
    @projects = @response.projects.find(:all, :include => :normal_activities)
    if @response.ready_to_submit?
      if current_response.organization.users.select{|u| u.activity_manager?}.
        map(&:email).present?
        Notifier.response_submitted_notification(@response).deliver
      end
      @response.submit!(current_user)
      flash[:notice] = "Successfully submitted. We will review your data and get back to you with any questions. Thank you."
      redirect_to review_response_url(@response)
    else
      @response.load_validation_errors
      render :review
    end
  end

  def reject
    @response.reject!(current_user)
    if current_response.organization.users.map(&:email).present?
      Notifier.response_rejected_notification(@response).deliver
    end
    render nothing: true
  end

  def accept
    @response.accept!(current_user)
    if current_response.organization.users.map(&:email).present?
      Notifier.response_accepted_notification(@response).deliver
    end
    flash[:notice] = "Response was successfully accepted"
    redirect_to :back
  end

  def generate_overview
    type = params[:type]
    if type == 'budget' || type == 'spend'
      report = Reports::Detailed::ResponseOverview.new(@response, type, 'xls')
      report.generate_report_for_download(current_user)

      flash[:notice] = "The report is being generated. A download link will be sent to #{current_user.email} when the report is ready."
      redirect_to reports_path
    else
      flash[:error] = "Report could not be generated. Please try again."
      redirect_to reports_path
    end
  end

  def download_overview
    type = params[:type]
    if type == 'budget' || type == 'spend'
      download_overview_report
    else
      flash[:error] = "Report could not be downloaded. Please try again."
      redirect_to reports_path
    end
  end

  private
    # use this if your controller expects :id instead of :response_id
    def load_response_from_id
      @response = find_response(params[:id])
    end

    def download_overview_report
      amount_type = params[:type] == 'budget' ? 'budget' : 'expenditure'
      if @response.send("#{amount_type}_overview_file_name")
        redirect_to @response.send("private_#{amount_type}_overview_url")
      else
        generate_overview
      end
    end
end
