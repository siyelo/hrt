module FileBuilder
  class Xlsx
    attr_accessor :filetype, :package, :workbook, :sheet

    def initialize
      @filetype = 'xlsx'
      @package  = Axlsx::Package.new
      @workbook = package.workbook
      @sheet    = workbook.add_worksheet
    end

    def add_row(row)
      sheet.add_row(row)
    end

    def data
      begin
        tempfile = Tempfile.new("temp_#{Time.now.to_s}.#{filetype}")
        package.serialize tempfile.path
        if block_given?
          yield(tempfile.read, filetype, mimetype)
        else
          tempfile.read
        end
      ensure
        tempfile.close
        tempfile.unlink
      end
    end

    def mimetype
      "application/vnd.ms-excel"
    end
  end
end
