require 'csv'

puts "\n  Loading inputs_v2.csv..."

CSV.foreach("db/seed_files/inputs_v2.csv", headers: true) do |row|
  code               = Input.find_or_initialize_by_external_id(row["id"])
  parent_code        = Input.find_by_external_id(row["parent_id"])
  code.parent_id     = parent_code.id if parent_code
  code.description   = row["description"]
  code.short_display = row["short_display"]
  code.version       = 2
  code.save!
  print "."
end
