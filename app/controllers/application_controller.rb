# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery
  helper_method :current_user_session, :current_user, :current_request,
    :current_response, :previous_response, :next_response,
    :current_user_response_for_current_request

  include ApplicationHelper
  include FileSender
  include UserAuthentication
  include ResponseSession

  layout :set_layout

  rescue_from ActionController::MethodNotAllowed do
    flash[:error] = "I'm sorry, that page is not available"
    redirect_to root_url
  end

  private

    def find_project(project_id)
      if current_user.sysadmin?
        Project.find(project_id)
      else
        current_user.current_response.projects.find(project_id)
      end
    end

    # Render detailed diagnostics for unhandled exceptions rescued from
    # a controller action.
    def rescue_action_locally(exception)
      class << RESCUES_TEMPLATE_PATH
        def [](path)
          if Rails.root.join("app/views", path).exist?
            ActionView::Template::EagerPath.new_and_loaded(Rails.root.join("app/views").to_s)[path]
          else
            super
          end
        end
      end
      super
    end

    def load_comment_resources(resource)
      @comment = Comment.new
      @comment.commentable = resource
      @comments = resource.comments.find(:all,
         :order => 'created_at DESC',
         :conditions => ['parent_id is NULL AND created_at > ?', DateTime.now - 6.months],
         :include => :user)
    end

    def load_klasses(field = :id) #TODO: deprecate id field - use only :mode
      @budget_klass, @spend_klass = case params[field]
      when 'purposes'
        [PurposeBudgetSplit, PurposeSpendSplit]
      when 'inputs'
        [InputBudgetSplit, InputSpendSplit]
      when 'locations'
        [LocationBudgetSplit, LocationSpendSplit]
      else
        raise "Invalid type #{params[field]}".to_yaml
      end
    end

    def load_klasses_from_mode
      load_klasses(:mode)
    end

    # http://stackoverflow.com/questions/4244507/headers-in-rails-cache-firefox-impropriety
    def prevent_browser_cache
      headers["Pragma"] = "no-cache"
      headers["Cache-Control"] = "must-revalidate"
      headers["Cache-Control"] = "no-cache"
      headers["Cache-Control"] = "no-store"
    end

    def warn_if_not_classified(outlay)
      if !outlay.classified?
        if flash[:warning].blank? && ( session['flash'].blank? ||
          session['warning'].present? && session['warning'][:notice].blank? )
          flash.now[:warning] = "This #{outlay.human_name} has not been fully classified.
            #{"<a href=\"#\" rel=\"#uncoded_overlay\" class=\"overlay\">Click here</a>
            to see what still needs to be classified"}"
        end
      end
    end

    def paginate_splits(outlay)
      @split_errors = outlay.implementer_splits.select{|is| !is.errors.empty?} unless outlay.errors.empty?
      unless @split_errors
        @splits = outlay.implementer_splits.sorted.paginate(:per_page => 50, :page => params[:page]) || outlay.implementer_splits
      end
    end

    def set_layout
      if devise_controller?
        if controller_name == 'passwords'
          'promo_landing'
        else
          'application'
        end
      else
        'application'
      end
    end
end
