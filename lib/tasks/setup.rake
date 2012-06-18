desc "Install gems and do db:setup (with seeds/fixtures)"
task :setup => ["db:setup", "db:populate"]

desc "Install gems create blank database"
task :setup_quick => ['db:drop', 'db:create', 'db:schema:load']
