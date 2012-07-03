module ReportExporter

  def to_xls
    builder = FileBuilder.new('xls')
    builder.add_row(build_header)
    collection.each do |report_row|
      row = build_row(report_row)
      builder.add_row(row)
    end
    builder.data
  end

  private
  def build_header
    ["Name", "Expenditure (#{unit})", "Budget (#{unit})"]
  end

  def build_row(report_row)
    [report_row.name, report_row.total_spend, report_row.total_budget]
  end
end
