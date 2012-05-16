module FileBuilder
  class Csv
    attr_accessor :filetype, :workbook

    def initialize
      @filetype = 'csv'
      @workbook = FasterCSV.new("")
    end

    def add_row(row)
      @workbook << row
    end

    def data
      if block_given?
        yield(workbook.string, filetype, mimetype)
      else
        workbook.string
      end
    end

    def mimetype
      "text/csv; charset=iso-8859-1; header=present"
    end
  end
end
