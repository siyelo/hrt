class RemoveHsspStrategicCodes < ActiveRecord::Migration
  def up
    Code.delete_all({:type => %w[HsspStratObj HsspStratProg]})
  end

  def down
    puts 'irreversible migration'
  end
end
