module ResponseSession

  def self.included(klass)
    klass.send(:include, InstanceMethods)
    klass.class_eval do
      before_filter :set_current_response
    end
  end

  module InstanceMethods
    def current_request
      current_response.data_request if current_response
    end

    def current_response
      @response
    end

    def previous_response
      response_for_request(current_request.previous_request)
    end

    def next_response
      response_for_request(current_request.next_request)
    end

    private
      def set_current_response
        set_response(detect_response)
      end

      def set_response(response)
        @response = response
        session[:response_id] = response.id if response
      end

      def detect_response
        return nil unless current_user

        resp_id = params[:response_id].presence || session[:response_id].presence
        resp = find_response(resp_id) if resp_id.present?
        resp ||= last_response
        resp = last_response if switch_to_last_response?(resp, last_response)

        resp
      end

      def last_response
        @last_response ||= current_user.organization.
          data_responses.latest_first.first
      end

      def find_response(response_id)
        if current_user.sysadmin?
          DataResponse.find_by_id(response_id)
        elsif current_user.activity_manager?
          # scope by the organizations the AM has access to
          DataResponse.find_by_id(response_id, :conditions => ["organization_id in (?)",
           [current_user.organization.id] + current_user.organizations.map{|o| o.id}])
        else
          current_user.data_responses.find_by_id(response_id)
        end
      end

      # TODO: add other report controllers
      def switch_to_last_response?(current_response, last_response)
        current_user.role?('reporter') && current_response != last_response &&
          !['reports', 'reports/projects'].include?(params[:controller])
      end

      def response_for_request(request)
        return nil if request.nil?
        current_response.organization.responses.find_by_data_request_id(request.id)
      end
  end
end
