class RemoveCodeSplitsWithoutActivity < ActiveRecord::Migration
  def up
    load 'db/fixes/20120710_remove_code_splits_without_activity.rb'
  end

  def down
    puts 'irreversible migration'
  end
end
