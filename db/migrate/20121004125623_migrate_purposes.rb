class MigratePurposes < ActiveRecord::Migration
  def up
    load 'db/fixes/20121004_migrate_purposes.rb'
  end

  def down
    puts 'irreversible migration'
  end
end
