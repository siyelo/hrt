require 'app/reports/classification_base'

module Reports
  class ActivityInputs < Reports::ClassificationBase
    def initialize(activity)
      @resource = activity
    end

    protected

    def activities
      [@resource]
    end

    def splits(type)
      "leaf_#{type}_inputs"
    end
  end
end
