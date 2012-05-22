class AddPreviousIdToCloneable < ActiveRecord::Migration
  def self.up
    add_column :data_responses, :previous_id, :integer
    add_column :projects, :previous_id, :integer
    add_column :activities, :previous_id, :integer
    add_column :funding_flows , :previous_id, :integer
    add_column :implementer_splits , :previous_id, :integer
  end

  def self.down
    remove_column :data_responses, :previous_id
    remove_column :projects, :previous_id
    remove_column :activities, :previous_id
    remove_column :funding_flows, :previous_id
    remove_column :implementer_splits, :previous_id
  end
end
