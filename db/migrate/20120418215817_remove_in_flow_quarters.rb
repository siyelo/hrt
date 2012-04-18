class RemoveInFlowQuarters < ActiveRecord::Migration
  def self.up
    remove_column :funding_flows, :spend_q1
    remove_column :funding_flows, :spend_q2
    remove_column :funding_flows, :spend_q3
    remove_column :funding_flows, :spend_q4
    remove_column :funding_flows, :budget_q1
    remove_column :funding_flows, :budget_q2
    remove_column :funding_flows, :budget_q3
    remove_column :funding_flows, :budget_q4
  end

  def self.down
  end
end
