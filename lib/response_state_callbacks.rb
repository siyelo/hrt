module ResponseStateCallbacks
  def self.included(base_class)
    base_class.class_eval do
      # Callbacks
      after_create  :start_response_if_unstarted
      after_destroy :unstart_response_if_no_data
    end
  end

  private

    def start_response_if_unstarted
      if response.unstarted?
        response.state = 'started'
        response.save!
      end
    end

    def unstart_response_if_no_data
      response.reload # reload for projects_count to update
      if !response.unstarted? && response.projects.empty? &&
          response.other_costs.without_a_project.empty?
        response.state = 'unstarted'
        response.save!
      end
    end
end
