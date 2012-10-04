class AddCommentsCountToWhereItIsMissing < ActiveRecord::Migration
  def self.up
    add_column :organizations, :comments_count, :integer, :default => 0
    add_column :funding_flows, :comments_count, :integer, :default => 0
  end

  def self.down
    remove_column :organizations, :comments_count
    remove_column :funding_flows, :comments_count
  end
end
