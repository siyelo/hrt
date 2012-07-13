module FileZipper
  extend self

  def unzip(file_path)
    output = nil
    Zip::ZipFile.open(file_path) do |files|
      output = files.first.get_input_stream.read.force_encoding("UTF-8")
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

  def zip_content(folder, file_name, content)
    File.open(folder + file_name, "w:UTF-8") {|f| f.write(content.force_encoding('UTF-8'))}
    zip(folder, file_name) do |zip_file_path|
      yield(zip_file_path)
    end
  end
end
