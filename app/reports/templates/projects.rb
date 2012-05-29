class Reports::Templates::Projects

  attr_accessor :builder

  def initialize(filetype)
    @builder = FileBuilder.new(filetype)
  end

  def data(&block)
    builder.add_row Reports::Detailed::ProjectsExport::FILE_UPLOAD_COLUMNS
    builder.data(&block)
  end

end

