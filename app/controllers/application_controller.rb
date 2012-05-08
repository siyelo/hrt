# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require "lib/hrt"

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery
  filter_parameter_logging :password, :password_confirmation
  helper_method :current_user_session, :current_user, :current_request,
    :current_response, :previous_response, :next_response

  include ApplicationHelper
  include SslRequirement
  include Exporter
  include UserAuthentication
  include ResponseSession

  rescue_from ActionController::MethodNotAllowed do
    flash[:error] = "I'm sorry, that page is not available"
    redirect_to root_url
  end

  protected
    # Require SSL for all actions in all controllers
    # redefined method from SSL requirement plugin
    # This method is redefined in static pages controller for actions: :index, :about, :contact, :news
    def ssl_required?
      if Rails.env == "production" || Rails.env == "staging" # || Rails.env == "development"
        true
      else
        false
      end
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
      # @comments = resource.comments.roots.find(:all)
      # :include => {:user => :organization} does not work when using roots scope
      # Comment.send(:preload_associations, @comments, {:user => :organization})
    end

    def load_klasses(field = :id) #TODO: deprecate id field - use only :mode
      @budget_klass, @spend_klass = case params[field]
      when 'purposes'
        [CodingBudget, CodingSpend]
      when 'inputs'
        [CodingBudgetCostCategorization, CodingSpendCostCategorization]
      when 'locations'
        [CodingBudgetDistrict, CodingSpendDistrict]
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
      type = outlay.class.to_s.titleize
      check_delayed_jobs_for(outlay)

      if outlay.approved? || outlay.am_approved?
        flash.now[:error] = "Classification for approved activity cannot be changed." unless flash[:error]
      elsif !outlay.classified?
        if flash[:warning].blank? && ( session['flash'].blank? ||
          session['warning'].present? && session['warning'][:notice].blank? )
          flash.now[:warning] = "This #{type} has not been fully classified.
            #{"<a href=\"#\" rel=\"#uncoded_overlay\" class=\"overlay\">Click here</a>
            to see what still needs to be classified"}"
        end
      else
        if flash[:notice].blank? && ( session['flash'].blank? ||
            session['flash'].present? && session['flash'][:notice].blank? )
          flash.now[:notice] = "This #{type} has been fully classified."
        end
      end
    end

    def check_delayed_jobs_for(outlay)
      dj = Delayed::Job.find(:first,
        :conditions => "handler LIKE '%object: LOAD;#{outlay.class.to_s};#{outlay.id}\nmethod: :update_classified_amount_cache_without_delay%'")

      if dj
        flash.now[:warning] = "We are still busy processing changes to the
          classification tree. Please reload the page to see whether this
          #{outlay.class.to_s.titleize} has been
          fully classified."
      end
    end

    def paginate_splits(outlay)
      @split_errors = outlay.implementer_splits.select{|is| !is.errors.empty?} unless outlay.errors.empty?
      unless @split_errors
        @splits = outlay.implementer_splits.sorted.paginate(:per_page => 50, :page => params[:page]) || outlay.implementer_splits
      end
    end
end
