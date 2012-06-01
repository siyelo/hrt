require 'app/reports/base'
require 'app/charts/base'

module Reports
  class Organization < Reports::Base
    def collection
      @collection ||= (@resource.projects + @resource.other_costs.without_project).
        sort{ |a, b| a.name.downcase <=> b.name.downcase }
    end

    def resource_link(element)
      if element.is_a?(::Project)
        reports_project_path(element)
      else
        reports_activity_path(element)
      end
    end

    def chart_links
      elements = Hash.new("")
      collection.each do |c|
        elements[c.try(:name).to_s.downcase.capitalize] = resource_link(c)
      end
      elements.to_json
    end

    def expenditure_chart
      Charts::Spend.new(collection).google_pie
    end

    def budget_chart
      Charts::Budget.new(collection).google_pie
    end
  end
end
