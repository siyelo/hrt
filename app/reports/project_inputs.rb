require 'app/reports/classification_base'

module Reports
  class ProjectInputs < Reports::ClassificationBase
    def initialize(project)
      @resource = project
    end

    protected

    def splits(type)
      "leaf_#{type}_inputs"
    end
  end
end
