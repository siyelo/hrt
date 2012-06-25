class RemoveOtherCostCodes < ActiveRecord::Migration
  def up
    load 'db/fixes/20120625102916_remove_other_cost_codes.rb'
  end

  def down
    puts "IRREVERSIBLE MIGRATION"
  end
end
