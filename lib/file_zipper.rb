module FileZipper
  extend self

  def unzip(file_path)
    output = nil
    Zip::ZipFile.open(file_path) do |files|
      output = files.first.get_input_stream.read.force_encoding("ASCII-8BIT")
    end
    output
  end

  def zip(folder, file_name)
    zip_file_path = "#{folder + file_name}.zip"

    Zip::ZipFile.open(zip_file_path, Zip::ZipFile::CREATE) do |zipfile|
        zipfile.add(file_name, folder + '/' + file_name)
    end

    yield(zip_file_path)

    File.delete(folder + file_name) if file_name
    File.delete(zip_file_path) if zip_file_path
  end
end
