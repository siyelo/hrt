module FileSender
  def send_csv(data, filename)
    send_file(data, filename, "text/csv; charset=iso-8859-1; header=present")
  end

  def send_report_file(report, filename)
    report.data do |content, filetype, mimetype|
      send_file(content, "#{filename}.#{filetype}", mimetype)
    end
  end

  def send_file(data, filename, mimetype)
    send_data data, :type => mimetype,
                    :disposition=>"attachment; filename=#{filename}"
  end

end
