require 'app/reports/classification_base'

module Reports
  class OrganizationInputs < Reports::ClassificationBase
    def initialize(response)
      @resource = response
    end

    protected

    def splits(type)
      "leaf_#{type}_inputs"
    end
  end
end
