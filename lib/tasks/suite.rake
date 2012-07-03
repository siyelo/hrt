namespace :test do
  task :suite do
    # Run all specs with in memory database
    ENV["IN_MEMORY_DB"] = '1'
    sh "bundle exec rspec spec"

    # Run non-javascript cukes with in memory database
    ENV["IN_MEMORY_DB"] = '1'
    sh "bundle exec cucumber features --tags ~@javascript --require features"

    # Run javascript cukes the standard way
    ENV["IN_MEMORY_DB"] = nil
    sh "bundle exec cucumber features --tags @javascript --require features"
  end
end
