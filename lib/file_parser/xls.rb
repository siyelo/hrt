module FileParser
  class Xls
    # converts xls string to array of hashes
    # string => [{:column1 => 1}, {:column1 => 2}]
    def self.parse(content)
      table = Spreadsheet.open(StringIO.new(content)).worksheet(0)
      rows = []
      (1..table.last_row_index).each do |index|
        rows << Hash[table.row(0).zip(table.row(index))]
      end

      rows
    end
  end
end
