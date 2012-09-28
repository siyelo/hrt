class LoadNewCodes < ActiveRecord::Migration
  def up
    Input.reset_column_information
    load 'db/seed_files/inputs_v2.rb'
  end

  def down
    puts 'irreversible migration'
  end
end
