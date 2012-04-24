module Charts::DataResponse
  class << self
    def data_response_status(data_request)
      data_responses = DataResponse.find :all,
        :select => 'data_responses.state, COUNT(*) AS count',
        :joins => :organization,
        :conditions => ["data_responses.data_request_id = ? AND
                        organizations.raw_type NOT IN (?)",
                        data_request.id, Organization::NON_REPORTING_TYPES],
        :group => "data_responses.state"
      build_chart_data(data_responses)
    end

    private

      def build_chart_data(data_responses)
        total = data_responses.map { |dr| dr.count.to_i }.sum

        [
          ['Responses'].concat(data_responses.map { |dr| dr.state.capitalize}),
          [''].concat(data_responses.map { |dr| dr.count.to_f * 100.0 / total.to_f })
        ].to_json
      end
  end
end

