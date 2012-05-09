require 'app/reports/classification_base'

module Reports
  class ProjectLocations < Reports::ClassificationBase
    def initialize(project)
      @resource = project
    end

    protected

    def splits(type)
      "coding_#{type}_district"
    end
  end
end
