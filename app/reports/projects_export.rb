class Reports::ProjectsExport
  include EncodingHelper
  include Reports::Helpers

  attr_accessor :builder

  ### Constants
  FILE_UPLOAD_COLUMNS = ["Project Name",
                         "On/Off Budget",
                         "Project Description",
                         "Project Start Date",
                         "Project End Date",
                         "Activity Name",
                         "Activity Description",
                         "Id",
                         "Implementer",
                         "Past Expenditure",
                         "Current Budget"]

  def initialize(response, filetype)
    @response = response
    @builder = FileBuilder.new(filetype)
  end

  def data(&block)
    build_rows
    builder.data(&block)
  end

  protected
  def build_rows
    builder.add_row(FILE_UPLOAD_COLUMNS)
    @response.projects.sorted.each do |project|
      row = []
      row << sanitize_encoding(project.name.slice(0..Project::MAX_NAME_LENGTH-1))
      row << project_budget_type(project)
      row << sanitize_encoding(project.description)
      row << project.start_date.to_s
      row << project.end_date.to_s
      if project.activities.empty?
        builder.add_row(row)
      else
        project.activities.roots.sorted.each_with_index do |activity, index|
          4.times do
            row << "" if index > 0 # dont re-print project details on each line
          end
          row << sanitize_encoding(activity.name.slice(0..Project::MAX_NAME_LENGTH-1))
          row << sanitize_encoding(activity.description)
          if activity.implementer_splits.empty?
            builder.add_row(row)
          else
            activity.implementer_splits.sorted.each_with_index do |split, index|
              7.times do
                row << "" if index > 0 # dont re-print activity details on each line
              end
              row << split.id
              row << split.organization_name
              row << split.spend.to_f
              row << split.budget.to_f
              builder.add_row(row)
              row = []
            end
          end
        end
      end
    end
  end
end
