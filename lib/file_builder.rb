module FileBuilder
  def self.new(filetype)
    case filetype
    when 'xlsx'
      Xlsx.new
    when 'xls'
      Xls.new
    when 'csv'
      Csv.new
    end
  end
end
