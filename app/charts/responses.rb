require 'app/charts/base'
require 'active_support/inflector' #for titleize

module Charts
  module Responses
    # Response States with Counts
    class State < Charts::Base
      class << self
        # the labels are the Response states
        def name_method
          :state
        end

        def name_format
          :titleize
        end

        def value_method
          :count
        end

        def value_format
          :to_i # format count as whole number
        end
      end

      def initialize(request_id)
        super responses_for_request(request_id)
      end

      def bar_sort
        self.sort_by_state
      end

      # sort in same order as the STATES are defined.
      def sort_by_state
        @data.sort_by{ |e| DataResponse::States::STATES.index e[0].downcase }
      end

      protected

      # All data response states for given request for reporting organizations
      # grouped by count
      def responses_for_request(request_id)
        DataResponse.find :all,
          :select => 'data_responses.state, COUNT(*) AS count',
          :joins => :organization,
          :conditions => ["data_responses.data_request_id = ? AND
                        organizations.raw_type NOT IN (?)",
                        request_id, Organization::NON_REPORTING_TYPES],
                        :group => "data_responses.state"
      end

      def bar_legend
        'Responses'
      end
    end
  end
end
