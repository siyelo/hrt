module User::ResponseSession

  def self.included(klass)
    klass.send(:include, InstanceMethods)

    klass.class_eval do
      ### Associations
      belongs_to :current_response, :class_name => "DataResponse", :foreign_key => :data_response_id_current

      ### Callbacks
      before_validation :assign_current_response_to_latest, :unless => Proc.new{|m| m.data_response_id_current.present?}

      ### Delegates
      delegate :responses, :to => :organization # instead of deprecated data_response
      delegate :latest_response, :to => :organization # find the last response in the org
    end
  end

  module InstanceMethods

    def current_request
      @current_request ||= self.current_response.nil? ? nil : self.current_response.request
    end

    def current_response_is_latest?
      self.current_response == self.latest_response
    end

    def set_current_response_to_latest!
      assign_current_response_to_latest
      self.save(false)
    end

    def change_current_response!(new_request_id)
      response = responses.find_by_data_request_id(new_request_id)
      if response
        self.current_response = response
        self.save(false)
      end
    end

    private

    def assign_current_response_to_latest
      if organization.present? && organization.data_responses.present?
        self.current_response = organization.latest_response
      end
    end
  end
end
