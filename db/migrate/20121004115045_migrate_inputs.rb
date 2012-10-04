class MigrateInputs < ActiveRecord::Migration
  def up
    load 'db/fixes/20121004_migrate_inputs.rb'
  end

  def down
    puts 'irreversible migration'
  end
end
