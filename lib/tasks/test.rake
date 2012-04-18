Rake::Task[:test].clear
desc "Run all tests"
task :test => %w[spec cucumber]

#override rspec default (:spec)
Rake::Task[:default].clear
desc 'Default: run specs and cukes'
task :default => :test

