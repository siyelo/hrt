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
      else
        name
      end
    when "reports/projects"
      case params[:action]
      when 'show'
        link_to name, reports_activity_path(element)
      else
        name
      end
    when "reports/activities"
      name
    when "admin/reports"
      case params[:action]
      when 'locations'
        link_to name, district_workplan_admin_reports_path(:district => element.name)
      else
        name
      end
    end
  end
end
