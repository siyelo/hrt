require 'csv'

def write_temp_xls(rows)
  # Spreadsheet.client_encoding = "UTF-8//IGNORE"
  book = Spreadsheet::Workbook.new
  sheet1 = book.create_worksheet

  rows.each_with_index do |row, row_index|
    row.each_with_index do |cell, column_index|
      sheet1[row_index, column_index] = cell
    end
  end
  filename =  File.join(Rails.root, 'tmp', 'temporary_spec.xls')
  book.write filename
  filename
end

def write_xls_with_header(rows)
  row = ['Project Name','On/Off Budget','Project Description','Project Start Date',
    'Project End Date','Activity Name','Activity Description',
    'Id','Implementer','Past Expenditure','Current Budget']
  rows.insert(0,row)
  write_temp_xls(rows)
end

def write_temp_csv(csv_string)
  filename =  File.join(Rails.root, 'tmp', 'temporary_spec.csv')
  CSV.open(filename, "w", :force_quotes => true) do |file|
    CSV.parse(csv_string).each do |line|
      file << line
    end
  end
  filename
end

def write_csv_with_header(csv_string)
  header = <<-EOS
Project Name,On/Off Budget,Project Description,Project Start Date,Project End Date,Activity Name,Activity Description,Id,Implementer,Past Expenditure,Current Budget
  EOS
  write_csv(header + csv_string)
end

def write_csv(csv_string)
  write_temp_csv(csv_string)
end

