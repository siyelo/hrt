module ResponseSession

  def self.included(klass)
    klass.send(:include, InstanceMethods)
    klass.class_eval do
      before_filter :set_current_response
      before_filter :set_url_options
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

    def current_user_response_for_current_request
      if current_request
        response = current_user.organization.data_responses.
          with_request(current_request.id).first
      end

      response ||= current_user.organization.data_responses.last
      response ? response.id : nil
    end

    private
      def set_current_response
        set_response(detect_response)
      end

      def set_url_options
        if current_response
          @url_options = { response_id: current_response.id }
        end
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
          DataResponse.find_by_id(response_id, conditions: ["organization_id in (?)",
           [current_user.organization.id] + current_user.organizations.map{|o| o.id}])
        else
          current_user.data_responses.find_by_id(response_id)
        end
      end

      def response_for_request(request)
        return nil if request.nil?
        current_response.organization.responses.find_by_data_request_id(request.id)
      end
  end
end
