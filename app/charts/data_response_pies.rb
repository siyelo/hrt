module Charts::DataResponsePies
  extend Charts::Helpers

  VIRTUAL_TYPES = [:budget_stratprog_coding, :spend_stratprog_coding,
   :budget_stratobj_coding, :spend_stratobj_coding]

  class << self
    def data_response_pie(data_response, codings_type = nil, code_type = nil)
      if VIRTUAL_TYPES.include?(codings_type.to_sym)
        get_virtual_codes(data_response.activities.roots, codings_type)
      else
        scope = Code.scoped({:conditions => ["data_responses.id = ?", data_response.id]})
        scope = scope.scoped({:conditions => ["code_assignments.type = ?", codings_type]}) if codings_type
        scope = scope.scoped({:conditions => ["codes.type = ?", code_type]}) if code_type
        codes = scope.find(:all,
              :select => "codes.id AS code_id,
                          codes.parent_id AS parent_id,
                          codes.short_display,
                          codes.short_display AS name,
                          SUM(code_assignments.cached_amount) AS value",
              :joins => {:code_assignments => {:activity => :data_response}},
              :group => "codes.short_display, codes.id, codes.parent_id",
              :order => 'value DESC')

        parent_ids = codes.collect{|n| n.parent_id.to_i} - [nil]
        parent_ids.uniq!
        # remove cached (parent) codes
        codes.reject{|ca| parent_ids.include?(ca.code_id.to_i)}
      end
    end

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

