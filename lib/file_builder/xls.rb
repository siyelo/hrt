module FileBuilder
  class Xls
    attr_accessor :filetype, :row_index, :workbook, :sheet

    def initialize
      Spreadsheet.client_encoding = "UTF-8//IGNORE"
      @filetype = 'xls'
      @workbook = Spreadsheet::Workbook.new
      @sheet    = workbook.create_worksheet
      @row_index = 0
    end

    def add_row(row)
      row.each_with_index do |cell, column_index|
        sheet[row_index, column_index] = cell
      end
      @row_index += 1
    end

    def data
      data = StringIO.new ''
      workbook.write data
      if block_given?
        yield(data.string, filetype, mimetype)
      else
        data.string
      end
    end

    def mimetype
      "application/vnd.ms-excel"
    end
  end
end
