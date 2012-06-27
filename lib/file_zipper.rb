module FileZipper
  extend self

  def unzip(file_path)
    cmd = "unzip -p #{file_path}"
    output = %x(#{cmd})
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
