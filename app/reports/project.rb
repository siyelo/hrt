require 'app/charts/base'
require 'active_support/core_ext/float'

module Reports
  class Project < Reports::Base
    def collection
      @resource.activities.sorted
    end

    def resource_link(element)
      reports_activity_path(element)
    end
  end
end
