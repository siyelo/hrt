module FileParser
  def self.parse(content, filetype, options = {})
    case filetype
    # when 'xlsx'
    #   Xlsx.new
    when 'xls'
      Xls.parse(content)
    when 'csv'
      Csv.parse(content, options)
    end
  end
end
