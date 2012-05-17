require 'app/charts/base'
require 'active_support/core_ext/float'

module Reports
  class Project < Reports::Base
    def collection
      @resource.activities.sorted
    end
  end
end
