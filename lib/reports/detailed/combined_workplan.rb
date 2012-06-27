class Reports::Detailed::CombinedWorkplan
  attr_accessor :response, :user, :filetype

  def initialize(response, user, filetype)
    @response = response
    @user = user
    @filetype = filetype
  end

  def generate_workplan_for_download
    generate_workplan
    Notifier.workplan_download_notification(user).deliver
  end
  handle_asynchronously :generate_workplan_for_download

  def generate_workplan
    workplan = Reports::Detailed::FunctionalWorkplan.new(
      response, user.organizations, filetype)
    workplan.data do |content, filetype, mimetype|
      folder = "#{Rails.root}/tmp/"
      file_name = "combined_workplan.#{filetype}"
      File.open(folder + file_name, "w:UTF-8") {|f| f.write(content.force_encoding('UTF-8'))}

      FileZipper.zip(folder, file_name) do |zip_file_path|
        user.workplan = File.new(zip_file_path, 'r')
        user.save
      end
    end
  end
end
