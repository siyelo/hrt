module ProjectsHelper
  def format_errors(errors)
    "<ul class='response-notice'>#{errors.map{|e| "<li>#{e}</li>"}.join}</ul>"
  end

  def create_or_edit_project_path(project, response)
    project.new_record? ? response_projects_path(response) : response_project_path(response, project)
  end
end
