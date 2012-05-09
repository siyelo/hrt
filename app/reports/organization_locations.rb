require 'app/reports/classification_base'

module Reports
  class OrganizationLocations < Reports::ClassificationBase
    def initialize(response)
      @resource = response
    end

    protected

    def splits(type)
      "coding_#{type}_district"
    end
  end
end
