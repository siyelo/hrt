namespace :db do
  desc "Loads initial database models for the current environment."
  task :populate => :environment do
    puts "Populating environment #{Rails.env}"
    Dir[File.join(Rails.root, 'db', 'fixtures', '*.rb')].sort.each { |fixture| puts "Loading #{fixture}\n"; load fixture }
    Dir[File.join(Rails.root, 'db', 'fixtures', Rails.env, '*.rb')].sort.each { |fixture| "Loading #{fixture}\n"; load fixture }
  end

  # this fixture file no long exists
  #task :populate_users => :environment do
  #  puts "Populating users in environment #{Rails.env}"
  #  load File.join(Rails.root, 'db', 'fixtures', '04_users.rb')
  #end

  desc "Resets user passwords for current environment."
  task :password_reset => :environment do
    puts "Reseting user passwords for environment #{Rails.env}"
    password = 'si@yelo'
    User.all.each{|u| u.password = password; u.password_confirmation = password; u.save}
    puts "------------------------------------------------------------------"
    puts "Passwords are reset to: '#{password}'"
    puts "------------------------------------------------------------------"
    puts "You can use following users for login:"
    puts "------------------------------------------------------------------"
    puts Organization.all.select{|o| o.users.count > 0}.map{|o| o.users.first.email}
    puts "------------------------------------------------------------------"
  end

  desc "Populates the database with currencies."
  task :load_currencies => :environment do
    require 'yaml'
    file = YAML.load_file "#{Rails.root}/db/seed_files/currencies.yml"
    puts "\nImporting currencies to the database\n"
    file.each do |currency|
      splits = currency[0].split('_TO_')
      from   = splits.first
      to     = splits.last
      Currency.create(:from => from, :to => to, :rate => currency[1])
    end
    puts "\nFinished importing currencies to the database\n"
  end
end
