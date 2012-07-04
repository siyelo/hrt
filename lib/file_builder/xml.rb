module FileBuilder
  class Xml
    attr_accessor :filetype, :workbook

    def initialize
      @filetype = 'xls'
      @workbook = []
    end

    def add_row(row)
      @workbook << row
    end

    def data
      excel = ExcelXML.new("HRT", workbook)

      if block_given?
        yield(excel.to_sheet, filetype, mimetype)
      else
        excel.to_sheet
      end
    end

    def mimetype
      "application/vnd.ms-excel"
    end
  end
end
