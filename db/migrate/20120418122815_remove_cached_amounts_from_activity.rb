class RemoveCachedAmountsFromActivity < ActiveRecord::Migration
  def self.up
    remove_column :activities, :budget
    remove_column :activities, :spend
  end

  def self.down
    add_column :activities, :budget, :decimal
    add_column :activities, :spend, :decimal
  end
end
