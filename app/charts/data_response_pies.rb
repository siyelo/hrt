module Charts::DataResponsePies
  class << self
    #pie chart displaying the status of the data responses
    def data_response_status_pie(data_request)
      data_responses = DataResponse.find :all,
        :select => 'data_responses.state, count(*) count',
        :conditions => ["data_responses.data_request_id = ?", data_request.id],
        :group => "data_responses.state"
      @pie = build_pie_chart(data_responses)
    end

    private

      def build_pie_chart(data_responses)
        response_statuses = data_responses.map { |dr| [dr.state, dr.count.to_i] }
        Charts::JsonHelpers.build_pie_values_json(response_statuses)
      end
  end
end

