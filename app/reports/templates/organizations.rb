class Reports::Templates::Organizations

  attr_accessor :organizations, :builder

  def initialize(organizations, filetype)
    @organizations = organizations
    @builder = FileBuilder.new(filetype)
  end

  def data(&block)
    build_rows
    builder.data(&block)
  end

  private
  def build_rows
    builder.add_row(Organization::FILE_UPLOAD_COLUMNS)
    organizations.each do |org|
      builder.add_row([org.name, org.raw_type, org.fosaid, org.currency])
    end
  end
end

