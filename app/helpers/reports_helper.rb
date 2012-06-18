module ReportsHelper

  def resource_link(element)
    element.link_path ? link_to(element.name, element.link_path) : element.name
  end
end
