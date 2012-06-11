require 'yaml'
require 'currency_helper'
file = YAML.load_file "#{Rails.root}/db/seed_files/currencies.yml"
puts "Importing currencies to the database\n"
file.each do |currency|
  splits = currency[0].split('_TO_')
  from   = splits.first
  to     = splits.last
  Currency.create!(:from => from, :to => to, :rate => currency[1])
end
puts "Finished importing currencies to the database\n"
