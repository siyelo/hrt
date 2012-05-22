require 'app/reports/base'
require 'app/charts/base'

module Reports
  class Organization < Reports::Base
    def collection
      @collection ||= (@resource.projects + @resource.other_costs.without_project).
        sort{ |a, b| a.name.downcase <=> b.name.downcase }
    end

    def resource_link(element)
      if element.is_a?(Project)
        reports_project_path(element)
      else
        reports_activity_path(element)
      end
    end

    def expenditure_pie
      Charts::Spend.new(collection).google_pie
    end

    def budget_pie
      Charts::Budget.new(collection).google_pie
    end
  end
end
