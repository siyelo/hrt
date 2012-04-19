module ProjectsHelper
  def create_or_edit_project_path(project, response)
    project.new_record? ? response_projects_path(response) : response_project_path(response, project)
  end
end
