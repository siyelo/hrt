class LoadNewCodes < ActiveRecord::Migration
  def up
    load 'db/seed_files/inputs_v2.rb'
  end

  def down
    puts 'irreversible migration'
  end
end
