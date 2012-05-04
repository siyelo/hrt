require 'yaml'

RAILS_ROOT = "#{File.dirname(__FILE__)}/../.." #unless defined?(RAILS_ROOT)

file = YAML.load_file "#{RAILS_ROOT}/db/seed_files/currencies.yml"
puts "Importing currencies to the database\n"
file.each do |currency|
  splits = currency[0].split('_TO_')
  from   = splits.first
  to     = splits.last
  Currency.create!(:from => from, :to => to, :rate => currency[1])
end
puts "Finished importing currencies to the database\n"
