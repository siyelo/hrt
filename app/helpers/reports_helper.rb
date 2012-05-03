module ReportsHelper

  # this will be expanded upon
  def resource_link(element)
    case params[:controller]

    when "reports"
      link_to element.name, reports_project_path(element.id)
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
