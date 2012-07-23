class RecalculateMissingCachedAmount < ActiveRecord::Migration
  def up
    load 'db/fixes/20120723154333_recalculate_missing_cached_amount.rb'
  end

  def down
    puts 'IRREVERSIBLE MIGRATION'
  end
end
