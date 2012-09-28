# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

puts "\n\nLoading seeds..."

load 'db/seed_files/codes.rb'

load 'db/seed_files/inputs.rb'
load 'db/seed_files/inputs_v2.rb'

load 'db/seed_files/beneficiaries.rb'

puts "...seeding DONE\n\n"
