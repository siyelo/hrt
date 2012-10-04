class FixCodesWithInvalidType < ActiveRecord::Migration
  def up
    load 'db/fixes/20121004_fix_codes_with_invalid_type.rb'
  end

  def down
    puts 'irreversible migration'
  end
end
