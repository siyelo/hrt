module FileParser
  class Csv
    def self.parse(content, options)
      CSV.parse(content, options)
    end
  end
end
