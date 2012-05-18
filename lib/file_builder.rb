module FileBuilder
  def self.new(filetype)
    case filetype
    when 'xlsx'
      Xlsx.new
    when 'xls'
      Xls.new
    when 'csv'
      Csv.new
    when 'xml'
      Xml.new
    end
  end
end
