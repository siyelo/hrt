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
      file_name = "#{Rails.root}/tmp/combined_workplan.#{filetype}"
      File.open(file_name, "w:US-ASCII") {|f| f.write(content)}

      FileZipper.zip(file_name) do |zip_file_name|
        user.workplan = File.new(zip_file_name, 'r')
        user.save
      end
    end
  end
end
