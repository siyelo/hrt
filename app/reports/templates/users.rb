class Reports::Templates::Users

  attr_accessor :builder

  def initialize(filetype)
    @builder = FileBuilder.new(filetype)
  end

  def data(&block)
    builder.add_row(User::FILE_UPLOAD_COLUMNS)
    builder.data(&block)
  end
end

