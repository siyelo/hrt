module ReportsHelper

  def resource_link(report, element)
    link = report.resource_link(element)
    link ? link_to(element.name, link) : element.name
  end
end
