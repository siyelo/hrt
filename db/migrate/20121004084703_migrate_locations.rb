class MigrateLocations < ActiveRecord::Migration
  def up
    load 'db/fixes/20121004_migrate_locations.rb'
  end

  def down
    puts 'irreversible migration'
  end
end
