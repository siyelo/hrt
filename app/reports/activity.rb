require 'app/charts/implementer_splits'
require 'active_support/core_ext/float'

module Reports
  class Activity < Reports::Base
    def collection
      @resource.implementer_splits.sorted.find(:all, :include => :organization)
    end

    def expenditure_chart
      Charts::ImplementerSplits::Spend.new(collection).google_pie
    end

    def budget_chart
      Charts::ImplementerSplits::Budget.new(collection).google_pie
    end
  end
end
