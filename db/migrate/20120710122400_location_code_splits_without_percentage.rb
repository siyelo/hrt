class LocationCodeSplitsWithoutPercentage < ActiveRecord::Migration
  def up
    load 'db/fixes/20120710_fix_location_code_splits_without_percentage.rb'
  end

  def down
    puts 'irreversible migration'
  end
end
