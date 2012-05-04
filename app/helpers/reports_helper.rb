module ReportsHelper

  # this will be expanded upon
  def resource_link(element)
    name = element.name || "no name"

    case params[:controller]

    when "reports"
      if element.is_a?(Project)
        link_to name, reports_project_path(element)
      else
        link_to name, reports_activity_path(element)
      end
    when "reports/projects"
      link_to name, reports_activity_path(element)
    when "reports/inputs"
      name
    when "reports/locations"
      name
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
