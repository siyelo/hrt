module FileParser
  class Csv
    def self.parse(content, options)
      FasterCSV.parse(content, options)
    end
  end
end
