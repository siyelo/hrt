class Code < ActiveRecord::Base
  extend CodeVersion
  extend TreeHelpers

  acts_as_nested_set
end

class RemoveHsspStrategicCodes < ActiveRecord::Migration
  def up
    Code.delete_all({:type => %w[HsspStratObj HsspStratProg]})
  end

  def down
    puts 'irreversible migration'
  end
end
