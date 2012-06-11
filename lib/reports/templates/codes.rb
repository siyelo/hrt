class Reports::Templates::Codes

  attr_accessor :builder

  def initialize(filetype)
    @builder = FileBuilder.new(filetype)
  end

  def data(&block)
    builder.add_row(Code::FILE_UPLOAD_COLUMNS)
    builder.data(&block)
  end

end

