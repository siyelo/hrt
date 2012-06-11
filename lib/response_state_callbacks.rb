module ResponseStateCallbacks
  def self.included(base_class)
    base_class.class_eval do
      # Callbacks
      after_save  :start_response_if_unstarted
      after_destroy :unstart_response_if_no_data
    end
  end

  private

    def start_response_if_unstarted
      if response && response.unstarted?
        if ((total_budget + total_spend) > 0) ||
           (self.class == Project && (in_flows_total_spend +
                                      in_flows_total_spend) > 0)
          response.state = 'started'
          response.save(validate: false)
        end
      end
    end

    def unstart_response_if_no_data
      if response
        response.reload # reload for projects_count to update
        if !response.unstarted? && response.projects.empty? &&
            response.other_costs.without_a_project.empty?
          response.state = 'unstarted'
          response.save(validate: false)
        end
      end
    end
end
