class Reports::Detailed::Users
  include Reports::Detailed::Helpers

  attr_accessor :builder

  def initialize(filetype)
    @users = User.find :all,
      include: [:organization],
      order: 'UPPER(users.full_name) ASC'
    @builder = FileBuilder.new(filetype)
  end

  def data(&block)
    build_rows
    builder.data(&block)
  end

  def create_report
    data do |content, filetype, mimetype|
      folder = "#{Rails.root}/tmp/"
      file_name = "users.#{filetype}"
      File.open(folder + file_name, "w:UTF-8") do |f|
        f.write(content.force_encoding('UTF-8'))
      end
    end
  end

  private
  def build_rows
    builder.add_row(build_header)
    @users.each do |user|
      builder.add_row(build_row(user))
    end
  end

  def build_header
    row = []
    row << 'Full Name'
    row << 'Email'
    row << 'Organization'
    row << 'Organization Contact Name'
    row << 'Organization Contact Position'
    row << 'Organization Contact Phone'
    row << 'Organization Contact Office Phone'
    row << 'Organization Contact Location'
    row
  end

  def build_row(user)
    row = []
    row << user.full_name
    row << user.email
    row << user.organization.try(:name)
    row << user.organization.try(:contact_name)
    row << user.organization.try(:contact_position)
    row << user.organization.try(:contact_phone_number)
    row << user.organization.try(:contact_main_office_phone_number)
    row << user.organization.try(:contact_office_location)
    row
  end
end
