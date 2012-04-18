puts "\nloading locations (districts)"

Location.delete_all

print "\n Seeding districts for rwanda"
FasterCSV.foreach("db/seed_files/districts.csv", :headers=>true) do |row|
  Location.create!(:short_display => row[0].strip)
  print "."
end
load 'db/seed_files/district_details.rb'
