require 'app/reports/classification_base'

module Reports
  class ActivityLocations < Reports::ClassificationBase
    def initialize(activity)
      @resource = activity
    end

    def currency
      @resource.data_response.currency
    end

    protected

    def activities
      [@resource]
    end

    def splits(type)
      "coding_#{type}_district"
    end
  end
end
