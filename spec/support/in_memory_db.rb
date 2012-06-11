if ENV["IN_MEMORY_DB"]
  puts '========== in memory db setup =========='
  load_schema = lambda {
    ActiveRecord::Base.establish_connection(Rails.configuration.database_configuration['test-in-memory'])
    ActiveRecord::Base.logger = Logger.new(File.open('log/database.log', 'a'))
    load "#{Rails.root}/db/schema.rb" # use db agnostic schema by default
    # ActiveRecord::Migrator.up('db/migrate') # use migrations
  }
  silence_stream(STDOUT, &load_schema)
end
