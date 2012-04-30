module User::ResponseSession

  def self.included(klass)
    klass.send(:include, InstanceMethods)

    klass.class_eval do
      ### Delegates
      delegate :responses, :to => :organization # instead of deprecated data_response
      delegate :latest_response, :to => :organization # find the last response in the org
    end
  end

  module InstanceMethods
    def current_response
      data_response_id_current? ? DataResponse.find(data_response_id_current) :
        latest_response
    end

    def current_response=(response)
      write_attribute :data_response_id_current, response.id
    end

    def current_request
      @current_request ||= self.current_response.nil? ? nil : self.current_response.request
    end

    def current_response_is_latest?
      self.current_response == self.latest_response
    end

    def change_current_response!(new_request_id)
      response = responses.find_by_data_request_id(new_request_id)
      if response
        self.current_response = response
        self.save(false)
      end
    end
  end
end
