require 'csv'

puts "\n  Loading inputs.csv..."

CSV.foreach("db/seed_files/inputs.csv", :headers=>true) do |row|
  c               = Input.find_or_initialize_by_external_id(row["id"])
  p               = Input.find_by_external_id(row["parent_id"])
  c.parent_id     = p.id unless p.nil?
  c.description   = row["description"]
  c.short_display = row["short_display"]
  puts "error on #{row}" unless c.save!
  print "."
end
