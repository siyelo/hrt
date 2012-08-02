module FileReader
  extend self

  def read(file)
    if is_zip?(file)
      attachment = FileZipper.unzip(file.path)
    else
      attachment = file.open.read.force_encoding("ASCII-8BIT")
    end
  end

  def file_format(file)
    File.extname(file.original_filename)
  end

  def valid_format?(file)
    ['.xls', '.zip'].include? file_format(file)
  end

  private
  def is_zip?(file)
    file_format(file) == ".zip"
  end

end
