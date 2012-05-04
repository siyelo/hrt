module ReportsHelper

  # this will be expanded upon
  def resource_link(element)
    name = element.name.presence || "no name"

    case params[:controller]
    when "reports"
      case params[:action]
      when 'index'
        if element.is_a?(Project)
          link_to name, reports_project_path(element)
        else
          link_to name, reports_activity_path(element)
        end
      when 'inputs'
        name
      when 'locations'
        name
      end
    when "reports/projects"
      link_to name, reports_activity_path(element)
    when "reports/activities"
      if element.is_a? Activity
        link_to name, reports_activity_path(element)
      else
        name
      end
    else
      name
    end
  end

  def unclassified_other_costs?
    unclassified_other_costs_spend != 0 ||
      unclassified_other_costs_budget != 0
  end

  def unclassified_other_costs_spend
    ( current_response.total_spend || 0 ) - ( @report.total_spend || 0)
  end

  def unclassified_other_costs_budget
    ( current_response.total_budget || 0 ) - ( @report.total_budget || 0)
  end
end
