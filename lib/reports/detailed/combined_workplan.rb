class Reports::Detailed::CombinedWorkplan
  include Rails.application.routes.url_helpers

  attr_accessor :response, :user, :filetype

  def initialize(response, user, filetype)
    @response = response
    @user = user
    @filetype = filetype
  end

  def generate_workplan_for_download
    generate_workplan
    Notifier.report_download_notification(user, download_workplans_url).deliver
  end
  handle_asynchronously :generate_workplan_for_download

  def generate_workplan
    workplan = Reports::Detailed::FunctionalWorkplan.new(
      response, user.organizations, filetype)
    workplan.data do |content, filetype, mimetype|
      folder = "#{Rails.root}/tmp/"
      file_name = "combined_workplan.#{filetype}"
      FileZipper.zip_content(folder, file_name, content) do |zip_file_path|
        user.workplan = File.new(zip_file_path, 'r')
        user.save
      end
    end
  end
end
