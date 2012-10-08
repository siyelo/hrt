class SetIsSpendOnCodeSplits < ActiveRecord::Migration
  def up
    load 'db/fixes/20121008_set_is_spend_on_code_splits.rb'
  end

  def down
    puts 'Irreversible migration'
  end
end
