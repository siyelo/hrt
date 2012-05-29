# In initialize method for report:
#   Reports::DynamicQuery
#   Reports::ClassificationSplit
#
# 1. define the data response ids by which you want to filter:
#    drs = [8225]
#
# 2. change the condition to filter by data_request_id
#    :conditions => ['data_responses.id IN (?) AND
#                     data_responses.data_request_id = ? AND
#                     data_responses.state = ?', drs, request.id, 'accepted']
#
# 3. Run this file with script/runner
#   ruby script/runner compare_reports.rb


def run_report(report, name)
  csv = report.csv
  File.open("#{name}.csv", 'w') do |f|
    f.puts csv
  end
  table = []
  FasterCSV.parse(csv, :headers => true) { |row| table << row }
  return table
end

def find_total(table, row_name)
  total = 0.0
  table.each_with_index do |row, index|
    total += table[index][row_name].gsub(/,/, '').to_f
  end
  total
end

data_request = DataRequest.last


table1 = run_report(Reports::Detailed::DynamicQuery.new(data_request, :spend), 'dynamic')
puts find_total(table1, 'Total Amount ($)')

table2 = run_report(Reports::Detailed::ClassificationSplit.new(data_request, :spend, :purpose), 'classification')
puts find_total(table2, 'Implementer Spend by Purpose ($)')
