module FileZipper
  extend self

  def unzip(file_path)
    cmd = "unzip -p #{file_path}"
    output = %x(#{cmd})
  end

  def zip(file_name)
    zip_file_name = "#{file_name}.zip"
    cmd = "zip -j -9 #{zip_file_name} #{file_name}"
    output = %x(#{cmd})

    yield(zip_file_name)

    File.delete(file_name) if file_name
    File.delete(zip_file_name) if zip_file_name
  end
end
