module ReportsHelper

  # this will be expanded upon
  def resource_link(element)
    case params[:controller]

    when "reports"
      if element.is_a?(Project)
        link_to element.name, reports_project_path(element)
      else
        link_to element.name, reports_activity_path(element)
      end
    when "reports/inputs"
      element.name
    when "reports/locations"
      element.name
    end
  end

  def unclassified_other_costs?
    unclassified_other_costs_spend != 0 ||
      unclassified_other_costs_budget != 0
  end

  def unclassified_other_costs_spend
    ( @response.total_spend || 0 ) - ( @report.total_spend || 0)
  end

  def unclassified_other_costs_budget
    ( @response.total_budget || 0 ) - ( @report.total_budget || 0)
  end
end
