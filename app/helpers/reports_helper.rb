module ReportsHelper

  # this will be expanded upon
  def resource_link(element)
    case params[:controller]

    when "reports"
      reports_project_path(element)
    end
  end
end
